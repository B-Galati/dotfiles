---
name: daily-recap
description: Reconstitue un résumé de ce que l'utilisateur a fait sur une journée donnée en croisant ses emails (Gmail), Slack, Linear et GitLab. Utilise ce skill dès que l'utilisateur demande un récap/résumé de sa journée, de sa semaine ou d'un jour précis — par exemple "résume ce que j'ai fait hier", "fais-moi un point sur ma journée", "qu'est-ce que j'ai fait lundi ?", "recap de la semaine" — même s'il ne mentionne aucune source explicitement.
disable-model-invocation: true
---

# Daily recap

Produit un résumé narratif et thématique de l'activité de l'utilisateur sur une période, en croisant Gmail, Slack, Linear et GitLab. But : lui redonner en quelques paragraphes ce qu'il a fait, décidé, débloqué ou attend — sans relire ses fils.

## 1. Période

Convertir l'expression relative en dates réelles à partir de la date du jour ("hier" = jour calendaire précédent, "cette semaine" = la plage correspondante). En cas d'ambiguïté sérieuse ("l'autre jour"), demander une fois ; sinon avancer avec l'hypothèse la plus probable et l'indiquer.

**Aucune période mentionnée → prendre "hier" par défaut** (ne pas demander).

**Ne jamais prendre en compte le samedi et le dimanche** : ce sont des jours non travaillés. Si la période par défaut (ou une borne calculée) tombe un week-end, reculer jusqu'au dernier jour ouvré — par ex. un lundi, "hier" = le vendredi précédent. Pour une plage type "cette semaine", exclure les week-ends de la collecte et de la synthèse.

## 2. Collecte — un subagent par source, en parallèle

Une fois la période résolue, **lancer un subagent `general-purpose` par source, tous dans un seul message (appels parallèles)**. Chaque source pagine beaucoup et renvoie du JSON verbeux : en confinant ce volume dans le contexte d'un subagent, on garde le contexte principal propre et on va plus vite. Chaque subagent charge lui-même ses outils MCP via `tool_search`, encaisse toute la pagination, et **ne renvoie qu'un digest compact déjà trié** (pas de dumps bruts) : liste des éléments à valeur avec canal/ticket/MR + heure + une phrase de contenu. S'il détecte que sa source n'est pas connectée, il renvoie simplement "source non connectée" — le contexte principal l'**ignore silencieusement** sans échouer.

Passer à chaque subagent : les dates exactes de la période et la consigne de digest ci-dessous. Les recettes techniques par source (à inclure dans le brief du subagent concerné) :

- **Gmail** — envois de l'utilisateur : `in:sent after:YYYY/MM/DD before:YYYY/MM/DD` (`before` exclusif = lendemain du dernier jour). Vue minimale pour trier ; `get_thread` seulement si un sujet mérite du détail.
- **Slack** — messages postés par l'utilisateur : `from:<@USER_ID> on:YYYY-MM-DD` (l'`USER_ID` est dans la description de l'outil Slack). **Toujours passer `include_context: false` et `sort: timestamp` ascendant** — le défaut `include_context: true` fait exploser la taille (une seule page peut dépasser 50k caractères et devenir illisible). **Paginer jusqu'au bout** en suivant le `cursor` (souvent 6–8 pages sur une journée active). Utiliser `slack_search_public_and_private` : demander son propre récap vaut consentement sur DMs et canaux privés. **Grouper le digest par `thread_ts`, un item par fil** (canal + sujet + où ça en est), jamais un item par message — sur une journée active un même thread concentre souvent 10–15 messages qui ne valent qu'une ligne.
- **Linear** — tickets touchés : `list_issues` avec `assignee:"me"`, `updatedAt:` = début de période, `orderBy:updatedAt` ; le filtre n'a pas de borne haute, donc écarter en post-traitement ceux mis à jour après la fin de période. Attention : `updatedAt`/`completedAt` sont en **UTC** (`Z`) — comparer à la fin de période convertie en UTC, et garder un jour de slop plutôt qu'un couperet strict pour ne pas perdre un ticket touché en soirée locale. `list_comments` sur un ticket clé si besoin de détail.
- **GitLab** — activité (push, MR, commentaires, actions issues) via la CLI. **Cibler le bon host** : `glab` peut avoir plusieurs instances configurées, et `gitlab.com` est souvent non authentifié (`glab api` sans flag y tape par défaut et échoue `401 Unauthenticated`). Lancer d'abord `glab auth status` pour repérer l'instance où l'utilisateur est loggé (ligne `✓ Logged in to <host> as <user>`), puis **passer `--hostname <host>`** avec le host détecté :
  ```
  glab api --hostname <host> "events?after=<veille>&before=<lendemain>&per_page=100"
  ```
  Bornes exclusives → élargir d'un jour de chaque côté, puis refiltrer sur les dates exactes. Le JSON est verbeux : **écrire un petit script de parsing dans un fichier** (pas d'inline `python3 -c` : les guillemets imbriqués cassent) et n'extraire que `created_at`, `action_name`, `target_type`, `target_title`, `push_data.ref/commit_count`, et pour les revues `note.body` + `note.position.new_path:new_line` — c'est là que se trouvent les commentaires de code à valeur (décisions, points bloquants). **Séparer dans le digest le travail livré (`pushed`/`pushed new`/MR `opened`/`accepted` par l'utilisateur) des reviews (`approved`/`commented on`)** — ce sont deux chantiers distincts dans la synthèse. **Garder `None`** : `push_data`, `commit_title`, `position` peuvent être absents (`(x or '')` avant tout slicing/indexing). Ignorer silencieusement si aucune instance n'est authentifiée.

## 3. Synthèse

Regrouper par **sujet / chantier**, pas par source ni par ordre chronologique brut. Croiser les sources sur un même sujet : un ticket Linear + sa MR GitLab + le fil Slack associé = un seul paragraphe. Pour chaque sujet, dire ce qui s'est passé et où ça en est (résolu, en attente, escaladé, à reprendre).

**Joindre les sources par identifiant, jamais par horodatage** : le numéro de ticket, le nom de branche et le numéro de MR (`expand-2139`, `!27`…) apparaissent dans les trois sources et sont la clé fiable pour rattacher un ticket Linear, sa MR GitLab et le fil Slack qui l'annonce. Ne pas corréler par l'heure : **les sources n'utilisent pas le même fuseau** — Linear renvoie de l'UTC (suffixe `Z`), Slack de l'heure locale, GitLab via `glab` s'affiche en local. Ce décalage impose aussi de garder un jour de slop au filtrage de bord (un ticket touché en soirée locale peut sortir en UTC le lendemain, ou l'inverse).

Signal > bruit : réponses d'agenda, "merci", emojis et blagues ne méritent pas un paragraphe — au plus une phrase globale, sinon ignorer. Remonter les éléments à valeur : décisions prises, blocages, engagements ("je m'en occupe vendredi"), passages de relais, et tout fil rouge transverse.

## 4. Sortie

Répondre directement dans la conversation (pas de fichier sauf demande), dans la langue de l'utilisateur, en **prose** :

- Une phrase d'ouverture situant la période et les sources.
- Un court paragraphe par sujet, le plus important d'abord (intitulé en gras en tête accepté ; éviter les listes à puces et la sur-structuration).
- Si pertinent, une dernière ligne sur le fil rouge de la journée.
- **En ouverture, clore par une courte liste de tâches à effectuer** (2–4 max), déduites des signaux de la période : blocages non résolus à relancer, MR encore en review à faire avancer, engagements pris ("je m'en occupe vendredi"), relances en attente de réponse, TODO explicites. Formuler chacune comme une action concrète et actionnable, pas comme un rappel vague.
- Terminer par **une seule** proposition d'approfondissement ciblée.

Rester factuel : ne rapporter que ce qui est dans les messages, sans extrapoler — les tâches proposées doivent découler d'éléments réellement présents (un engagement, un blocage, une MR ouverte), jamais d'une extrapolation.
