---
name: daily-recap
description: Reconstitue un résumé de ce que l'utilisateur a fait sur une journée donnée en croisant ses emails (Gmail), Slack, Linear, GitLab et son agenda (Google Calendar). Utilise ce skill dès que l'utilisateur demande un récap/résumé de sa journée, de sa semaine ou d'un jour précis — par exemple "résume ce que j'ai fait hier", "fais-moi un point sur ma journée", "qu'est-ce que j'ai fait lundi ?", "recap de la semaine" — même s'il ne mentionne aucune source explicitement.
disable-model-invocation: true
---

# Daily recap

Produit un résumé narratif et thématique de l'activité de l'utilisateur sur une période, en croisant Gmail, Slack, Linear, GitLab et Google Calendar. But : lui redonner en quelques paragraphes ce qu'il a fait, décidé, débloqué ou attend — sans relire ses fils.

## 1. Période

Convertir l'expression relative en dates réelles à partir de la date du jour ("hier" = jour calendaire précédent, "cette semaine" = la plage correspondante). En cas d'ambiguïté sérieuse ("l'autre jour"), demander une fois ; sinon avancer avec l'hypothèse la plus probable et l'indiquer.

**Aucune période mentionnée → prendre "hier" par défaut** (ne pas demander).

**Ne jamais prendre en compte le samedi et le dimanche** : ce sont des jours non travaillés. Si la période par défaut (ou une borne calculée) tombe un week-end, reculer jusqu'au dernier jour ouvré — par ex. un lundi, "hier" = le vendredi précédent. Pour une plage type "cette semaine", exclure les week-ends de la collecte et de la synthèse.

## 2. Collecte — un subagent par source, en parallèle

Une fois la période résolue, **lancer un subagent `general-purpose` par source, tous dans un seul message (appels parallèles)**. Chaque source pagine beaucoup et renvoie du JSON verbeux : en confinant ce volume dans le contexte d'un subagent, on garde le contexte principal propre et on va plus vite. Chaque subagent charge lui-même ses outils MCP via `tool_search`, encaisse toute la pagination, et **ne renvoie qu'un digest compact déjà trié** (pas de dumps bruts) : liste des éléments à valeur avec canal/ticket/MR + heure + une phrase de contenu.

**Chaque item du digest doit porter son URL canonique** (voir les champs à récupérer par source ci-dessous). C'est indispensable : la sortie finale contient une liste de liens cliquables, et une URL ne se reconstruit pas après coup depuis le contexte principal — un permalink Slack non capturé pendant la collecte est perdu. Un subagent qui renvoie un digest sans URL a raté sa mission. S'il détecte que sa source n'est pas connectée, il renvoie simplement "source non connectée" — le contexte principal l'**ignore silencieusement** sans échouer.

Passer à chaque subagent : les dates exactes de la période et la consigne de digest ci-dessous. Les recettes techniques par source (à inclure dans le brief du subagent concerné) :

- **Gmail** — envois de l'utilisateur : `in:sent after:YYYY/MM/DD before:YYYY/MM/DD` (`before` exclusif = lendemain du dernier jour). Vue minimale pour trier ; `get_thread` seulement si un sujet mérite du détail. **Garder l'id de thread** : l'URL est `https://mail.google.com/mail/u/0/#all/<threadId>`.
- **Slack** — messages postés par l'utilisateur : `from:<@USER_ID> on:YYYY-MM-DD` (l'`USER_ID` est dans la description de l'outil Slack). **Toujours passer `include_context: false` et `sort: timestamp` ascendant** — le défaut `include_context: true` fait exploser la taille (une seule page peut dépasser 50k caractères et devenir illisible). **Paginer jusqu'au bout** en suivant le `cursor` (souvent 6–8 pages sur une journée active). Utiliser `slack_search_public_and_private` : demander son propre récap vaut consentement sur DMs et canaux privés. **Grouper le digest par `thread_ts`, un item par fil** (canal + sujet + où ça en est), jamais un item par message — sur une journée active un même thread concentre souvent 10–15 messages qui ne valent qu'une ligne. **Conserver le champ `permalink`** du message le plus représentatif du fil (celui qui porte la décision, sinon le premier de l'utilisateur) : c'est l'URL de l'item. Le recopier tel quel, avec ses paramètres `?thread_ts=…&cid=…` — ne jamais fabriquer un permalink à la main à partir du channel id et du `ts`.
- **Linear** — tickets touchés : `list_issues` avec `assignee:"me"`, `updatedAt:` = début de période, `orderBy:updatedAt` ; le filtre n'a pas de borne haute, donc écarter en post-traitement ceux mis à jour après la fin de période. Attention : `updatedAt`/`completedAt` sont en **UTC** (`Z`) — comparer à la fin de période convertie en UTC, et garder un jour de slop plutôt qu'un couperet strict pour ne pas perdre un ticket touché en soirée locale. `list_comments` sur un ticket clé si besoin de détail. **Garder le champ `url` de chaque issue** (l'identifiant type `EXP-2139` sert de libellé, l'`url` de lien).
- **Google Calendar** — réunions et créneaux de la période : `list_events` sur le calendrier principal avec `time_min`/`time_max` bornés à la période (inclure le fuseau local, sinon les événements de début/fin de journée sont coupés). Ne pas appeler `list_calendars` sauf si le principal ne renvoie rien. **Écarter ce qui n'a pas eu lieu** : événements où l'utilisateur a répondu `declined`, et invitations restées `needsAction` sur un créneau où il était visiblement ailleurs (à signaler comme "invité, pas de réponse" plutôt que comme réunion faite). **Écarter le bruit d'agenda** : blocs perso récurrents, "Focus time", "Lunch", rappels sans participants — sauf s'ils expliquent un trou dans la journée (OOO, congé, déplacement), auquel cas une seule ligne suffit. Pour les réunions à valeur, remonter dans le digest : heure + durée, titre, nombre/nom des participants clés, et le descriptif ou l'ordre du jour s'il existe (`get_event` seulement sur une réunion clé dont le contenu compte). **URL de l'item : privilégier le lien de document trouvé dans la description** (page Notion d'ordre du jour, doc Google, ticket) — c'est ce que l'utilisateur veut rouvrir, pas la case agenda ; à défaut seulement, le `htmlLink` de l'événement. Un lien de visio (Meet, Zoom) n'est jamais l'URL d'un item : il ne mène nulle part après la réunion. **Signaler les réunions annulées** et celles où l'utilisateur était organisateur — un point qu'il a lui-même provoqué est un signal plus fort qu'une réunion subie.

  **Second appel, en avant de la période** : `list_events` sur le **prochain jour ouvré après la fin de période** (vendredi → lundi ; jamais un samedi ou un dimanche). C'est la seule source qu'on lit dans le futur — ne pas étendre les autres. Digest à part, clairement étiqueté "à venir", même tri du bruit (declined, Focus time, blocs perso écartés) et, pour chaque réunion retenue : heure, titre, participants clés, ordre du jour s'il existe. Ne pas aller au-delà de ce jour : un récap n'est pas une revue de semaine à venir.
- **GitLab** — activité (push, MR, commentaires, actions issues) via la CLI. **Cibler le bon host** : `glab` peut avoir plusieurs instances configurées, et `gitlab.com` est souvent non authentifié (`glab api` sans flag y tape par défaut et échoue `401 Unauthenticated`). Lancer d'abord `glab auth status` pour repérer l'instance où l'utilisateur est loggé (ligne `✓ Logged in to <host> as <user>`), puis **passer `--hostname <host>`** avec le host détecté :
  ```
  glab api --hostname <host> "events?after=<veille>&before=<lendemain>&per_page=100"
  ```
  Bornes exclusives → élargir d'un jour de chaque côté, puis refiltrer sur les dates exactes. Le JSON est verbeux : **écrire un petit script de parsing dans un fichier** (pas d'inline `python3 -c` : les guillemets imbriqués cassent) et n'extraire que `created_at`, `action_name`, `target_type`, `target_title`, `project_id`, `target_iid` (ou `note.noteable_iid`), `push_data.ref/commit_count`, et pour les revues `note.body` + `note.position.new_path:new_line` — c'est là que se trouvent les commentaires de code à valeur (décisions, points bloquants). **Séparer dans le digest le travail livré (`pushed`/`pushed new`/MR `opened`/`accepted` par l'utilisateur) des reviews (`approved`/`commented on`)** — ce sont deux chantiers distincts dans la synthèse. **Garder `None`** : `push_data`, `commit_title`, `position` peuvent être absents (`(x or '')` avant tout slicing/indexing). Ignorer silencieusement si aucune instance n'est authentifiée.

  **URL des items** : les events ne portent pas de `web_url`. Résoudre le chemin projet une fois par `project_id` distinct (`glab api --hostname <host> projects/<id>` → `path_with_namespace`, quelques projets par jour au plus, donc mettre en cache) puis construire `https://<host>/<path_with_namespace>/-/merge_requests/<iid>`. Un push sans MR n'a pas d'URL utile : le rattacher à la MR de sa branche s'il y en a une, sinon laisser l'item sans lien.

## 3. Synthèse

Regrouper par **sujet / chantier**, pas par source ni par ordre chronologique brut. Croiser les sources sur un même sujet : un ticket Linear + sa MR GitLab + le fil Slack associé = un seul paragraphe. Pour chaque sujet, dire ce qui s'est passé et où ça en est (résolu, en attente, escaladé, à reprendre).

**L'agenda sert de trame, pas de sujet à part** : une réunion se rattache au chantier qu'elle concerne (rapprochée par son titre, ses participants ou le ticket qu'elle cite), et le paragraphe dit ce qui en est sorti — décision, arbitrage, relais — en le corroborant par ce qui a suivi dans Slack ou Linear. Ne pas faire un paragraphe "réunions du jour". L'agenda explique aussi les creux : une matinée sans commit ni message se lit tout de suite si trois réunions l'occupaient, et une journée saturée mérite une phrase le disant. Une réunion sans aucune trace ailleurs ne vaut au mieux qu'une mention en passant.

**Les réunions à venir ne prennent jamais de paragraphe** : elles n'appartiennent pas au récap, qui raconte une période écoulée. Elles ne servent qu'à alimenter la liste de tâches — et seulement quand elles croisent un sujet réellement traité dans la période.

**Joindre les sources par identifiant, jamais par horodatage** : le numéro de ticket, le nom de branche et le numéro de MR (`expand-2139`, `!27`…) apparaissent dans les trois sources et sont la clé fiable pour rattacher un ticket Linear, sa MR GitLab et le fil Slack qui l'annonce. Ne pas corréler par l'heure : **les sources n'utilisent pas le même fuseau** — Linear renvoie de l'UTC (suffixe `Z`), Slack de l'heure locale, GitLab via `glab` s'affiche en local, Google Calendar des datetimes avec offset explicite (et une date seule pour les journées entières). Seule exception tolérée : situer grossièrement une réunion dans la journée pour expliquer un creux d'activité — jamais pour affirmer qu'une réunion a causé un commit ou un message précis. Ce décalage impose aussi de garder un jour de slop au filtrage de bord (un ticket touché en soirée locale peut sortir en UTC le lendemain, ou l'inverse).

Signal > bruit : réponses d'invitation, "merci", emojis et blagues ne méritent pas un paragraphe — au plus une phrase globale, sinon ignorer. Remonter les éléments à valeur : décisions prises, blocages, engagements ("je m'en occupe vendredi"), passages de relais, et tout fil rouge transverse.

## 4. Sortie

Répondre directement dans la conversation (pas de fichier sauf demande), dans la langue de l'utilisateur, en **prose** :

- Une phrase d'ouverture situant la période et les sources.
- Un court paragraphe par sujet, le plus important d'abord (intitulé en gras en tête accepté ; éviter les listes à puces et la sur-structuration).
- Si pertinent, une dernière ligne sur le fil rouge de la journée.
- **En ouverture, clore par une courte liste de tâches à effectuer** (2–4 max), déduites des signaux de la période : blocages non résolus à relancer, MR encore en review à faire avancer, engagements pris ("je m'en occupe vendredi"), relances en attente de réponse, TODO explicites, suites de réunion restées sans trace (une décision prise en réunion mais aucun ticket ni message derrière), invitations laissées sans réponse, et **préparation d'une réunion du prochain jour ouvré** quand elle porte sur un sujet de la période. Formuler chacune comme une action concrète et actionnable, pas comme un rappel vague.
- Pour une réunion à venir, la tâche doit nommer **ce qu'il y a à préparer** et d'où ça vient : un point resté en suspens, une MR à faire relire, des chiffres promis, un ordre du jour explicite. « Tu as un point archi demain » n'est pas une tâche — « finir le comparatif de migration avant le point archi de 10h » en est une. **Aucun sujet de la période qui recoupe la réunion → ne pas en faire une tâche** : le simple fait qu'un créneau existe ne se déduit de rien.
- **Une** proposition d'approfondissement ciblée.
- Puis, en tout dernier, la liste copiable décrite en §5.

Rester factuel : ne rapporter que ce qui est dans les messages, sans extrapoler — les tâches proposées doivent découler d'éléments réellement présents (un engagement, un blocage, une MR ouverte), jamais d'une extrapolation.

## 5. Liste copiable des choses faites

Clore la réponse par une liste markdown de ce qui a été fait, destinée au copier/coller dans les notes de l'utilisateur. **La mettre dans un bloc de code (```markdown)** : elle doit être copiée telle quelle, syntaxe des liens comprise — un lien rendu par le terminal n'est plus collable.

Ne pas confondre avec la liste de tâches du §4 : ici c'est le **fait**, pas le à faire.

Format exact, une ligne par élément :

```markdown
- Weekly Team Sync [[notion](https://app.notion.com/p/acme/weekly-0000000000000000000000000000abcd)]
- Retry policy on the worker pool [[linear](https://linear.app/acme/issue/PLAT-1234/retry-policy-on-the-worker-pool)] [[MR](https://gitlab.acme.dev/platform/app/-/merge_requests/1234)] [[slack](https://acme.slack.com/archives/C0000AAAA00/p1700000000111111?thread_ts=1699000000.222222&cid=C0000AAAA00)]
- Rollout cache warmup on the ingest pipeline [[slack](https://acme.slack.com/archives/C0000AAAA00/p1700000000444444?thread_ts=1699000000.555555&cid=C0000AAAA00)]
- Flaky integration tests triage [[linear](https://linear.app/acme/issue/PLAT-1240/flaky-integration-tests)] [[MR](https://gitlab.acme.dev/platform/app/-/merge_requests/1251)]
- Onboarding doc for the new SDK [[slack](https://acme.slack.com/archives/C0000BBBB00/p1700000000333333)]
```

Règles :

- **Un libellé court, repris de la source** — titre de MR, de ticket, de réunion, sujet du fil — pas une phrase reformulée et **pas de traduction** : le libellé doit rester reconnaissable dans l'outil d'origine.
- **Un lien par trace utile, pas un par élément** : un même sujet a souvent vécu dans plusieurs outils, et les cumuler est le cas normal — `- Retry policy on the worker pool [[linear](…)] [[MR](…)] [[slack](…)]`. Chaque lien entre doubles crochets, séparés par une espace, label en minuscules d'après la source (`slack`, `notion`, `linear`, `mail`, `agenda`, `doc`) sauf `MR` en majuscules.
- **Toujours le même ordre** de gauche à droite — `linear` → `MR` → `slack`/`mail` → `notion`/`doc`/`agenda` — pour que la liste se relise en colonne. Le premier lien est le point d'entrée : le ticket s'il existe, sinon la MR, sinon le fil.
- **Ne cumuler que ce qui ajoute quelque chose** : trois fils Slack sur le même chantier se réduisent au plus décisif, et deux ou trois liens par ligne suffisent presque toujours. Au-delà de quatre, c'est que la ligne mélange deux sujets — la couper en deux.
- **Jamais d'URL inventée ou reconstruite de mémoire.** N'utiliser que les URLs remontées par les subagents. Si un élément n'en a pas, le lister sans lien plutôt que de le supprimer ou de deviner.
- **Granularité : un élément = une chose faite**, alignée sur les sujets de la prose et dans le même ordre. Trois messages et une MR sur le même chantier font une seule ligne. Viser une liste dense qu'on relit d'un coup d'œil, pas un journal exhaustif.
- Écarter le bruit déjà écarté dans la prose : réunions subies sans suite, accusés de réception, réponses d'invitation.
