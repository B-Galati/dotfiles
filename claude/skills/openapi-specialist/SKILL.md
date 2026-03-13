---
name: openapi-specialist
description: OpenAPI specification expert for creating, improving, and validating clear, self-documenting API specs. Use when designing, reviewing, or refactoring OpenAPI/Swagger specs for clarity, consistency, and usability.
---

# OpenAPI Specialist Skill

This skill provides expert guidance for creating, improving, and maintaining high-quality OpenAPI specifications that are self-documenting and easy to consume.

## Tool

Use `make oas-lint` to validate your changes at the end.

## When to Use This Skill

Use this skill when:
- **Creating new API specs** from scratch or from existing endpoints
- **Reviewing and improving** existing OpenAPI specifications
- **Refactoring specs** for clarity and consistency
- **Validating specs** against best practices
- **Generating API documentation** from specs
- **Ensuring API contracts** between frontend and backend
- **Creating reusable components** (schemas, responses, parameters)
- **Setting up spec linting** and validation

---

## Core Principles

### 1. Self-Documenting Specifications

The spec should be understandable **without external documentation**:
- Clear descriptions for every endpoint, parameter, and field
- Meaningful examples that demonstrate real-world usage
- Explanatory titles and summaries

```yaml
# ✅ GOOD - Self-documenting
/workflows/{id}:
  get:
    summary: Retrieve a specific workflow
    description: |
      Fetches a workflow by ID along with all its associated metadata.
      Requires read access to the workflow's workspace.
    operationId: getWorkflow
    parameters:
      - name: id
        in: path
        required: true
        description: The UUID of the workflow to retrieve
        schema:
          type: string
          format: uuid
    responses:
      '200':
        description: Workflow retrieved successfully
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Workflow'

# ❌ POOR - Unclear and vague
/workflows/{id}:
  get:
    summary: Get workflow
    operationId: getWorkflowById
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
```

### 2. Consistency Over Convention

- **Consistent naming**: Use same verb/noun patterns across endpoints
- **Consistent response structures**: All errors follow the same format
- **Consistent parameter styles**: Consistent naming for query params, paths, headers
- **Consistent examples**: Real, working examples throughout

### 3. Type Safety and Precision

- Every field has a type and constraints
- No untyped objects or `additionalProperties: true` without reason
- Use enums for finite sets of values
- Include `minLength`, `maxLength`, `pattern` for strings
- Include `minimum`, `maximum` for numbers

```yaml
# ✅ PRECISE
properties:
  name:
    type: string
    minLength: 1
    maxLength: 255
    description: The workflow name
  status:
    type: string
    enum: [draft, active, archived]
    description: Current workflow state
  priority:
    type: integer
    minimum: 0
    maximum: 4
    description: Priority level (0=none, 1=urgent, 4=low)

# ❌ VAGUE
properties:
  name:
    type: string
  status:
    type: string
  priority:
    type: integer
```

### 4. DRY (Don't Repeat Yourself)

- Use `$ref` to reference common schemas
- Create reusable components for pagination, errors, timestamps
- Use parameter definitions for repeated parameters
- Group related endpoints under the same tag

---

## OpenAPI Structure Best Practices

### Root Level Organization

```yaml
openapi: 3.1.0
info:
  title: Yousign API
  version: 3.0.0
  description: |
    The Yousign document signing and workflow API.

    ## Authentication
    Use Bearer tokens in the Authorization header:
    ```
    Authorization: Bearer your-api-token
    ```

    ## Rate Limiting
    Requests are limited to 100 per minute per API token.
  contact:
    name: Yousign Support
    url: https://support.yousign.com
    email: support@yousign.com
  license:
    name: Proprietary
    url: https://yousign.com/legal

servers:
  - url: https://api.yousign.com/v3
    description: Production API
  - url: https://sandbox.yousign.com/v3
    description: Sandbox for testing

tags:
  - name: Workflows
    description: Workflow management and execution
  - name: Signatures
    description: Signature requests and tracking
  - name: Documents
    description: Document upload and management

paths:
  # ... endpoints here

components:
  # ... schemas, responses, parameters here
```

### Endpoint Organization

```yaml
paths:
  /workflows:
    get:
      tags: [Workflows]
      summary: List workflows
      operationId: listWorkflows
      description: |
        Retrieves a paginated list of workflows in the authenticated user's workspace.
        Results are ordered by creation date (newest first).
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/LimitParam'
        - name: status
          in: query
          schema:
            type: string
            enum: [draft, active, archived]
          description: Filter by workflow status
      responses:
        '200':
          $ref: '#/components/responses/WorkflowList'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'

    post:
      tags: [Workflows]
      summary: Create a workflow
      operationId: createWorkflow
      description: Creates a new workflow in the authenticated user's workspace.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateWorkflowInput'
            examples:
              basic:
                summary: Basic workflow creation
                value:
                  name: Sales Agreement Review
                  description: Contract review process
      responses:
        '201':
          description: Workflow created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Workflow'
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'
```

---

## Schema Design Best Practices

### 1. Reusable Schemas

Create base schemas that are composed into others:

```yaml
components:
  schemas:
    # Base schemas (used as building blocks)
    Timestamp:
      type: object
      properties:
        createdAt:
          type: string
          format: date-time
          description: When the resource was created
        updatedAt:
          type: string
          format: date-time
          description: When the resource was last updated
      required: [createdAt, updatedAt]

    # UUID reference
    IdField:
      type: string
      format: uuid
      description: Unique identifier

    # Error response
    ErrorResponse:
      type: object
      properties:
        type:
          type: string
          description: Machine-readable error type
        title:
          type: string
          description: Human-readable error title
        detail:
          type: string
          description: Detailed explanation
        status:
          type: integer
          description: HTTP status code
      required: [type, title, status]

    # Pagination metadata
    PaginationMeta:
      type: object
      properties:
        page:
          type: integer
          minimum: 1
          description: Current page number
        limit:
          type: integer
          minimum: 1
          maximum: 100
          description: Items per page
        total:
          type: integer
          description: Total number of items
        pages:
          type: integer
          description: Total number of pages
      required: [page, limit, total, pages]

    # Domain models
    Workflow:
      allOf:
        - $ref: '#/components/schemas/IdField'
        - $ref: '#/components/schemas/Timestamp'
        - type: object
          properties:
            name:
              type: string
              minLength: 1
              maxLength: 255
              description: Workflow name
            status:
              type: string
              enum: [draft, active, archived]
              description: Current status
            workspaceId:
              $ref: '#/components/schemas/IdField'
            creatorId:
              $ref: '#/components/schemas/IdField'
          required: [id, name, status, workspaceId, creatorId, createdAt, updatedAt]

    # Input schemas
    CreateWorkflowInput:
      type: object
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 255
          description: Workflow name
        description:
          type: string
          maxLength: 1000
          description: Optional workflow description
        workspaceId:
          $ref: '#/components/schemas/IdField'
      required: [name, workspaceId]
```

### 2. Composition Over Inheritance

Prefer `allOf` for composing schemas:

```yaml
# ✅ GOOD - Composable
Workflow:
  allOf:
    - $ref: '#/components/schemas/BaseEntity'
    - $ref: '#/components/schemas/Timestamps'
    - type: object
      properties:
        name: { type: string }

# ❌ AVOID - Duplication
Workflow:
  type: object
  properties:
    id: { type: string, format: uuid }
    createdAt: { type: string, format: date-time }
    updatedAt: { type: string, format: date-time }
    name: { type: string }
```

### 3. Clear Required Fields

Always specify `required` arrays:

```yaml
# ✅ EXPLICIT
User:
  type: object
  properties:
    id:
      type: string
      format: uuid
    email:
      type: string
      format: email
    name:
      type: string
    role:
      type: string
      enum: [admin, user, viewer]
  required: [id, email, name]  # role is optional

# ❌ UNCLEAR - Which fields are required?
User:
  type: object
  properties:
    id:
      type: string
      format: uuid
    email:
      type: string
      format: email
    name:
      type: string
    role:
      type: string
      enum: [admin, user, viewer]
```

---

## Response Design

### 1. Consistent Error Responses

```yaml
components:
  responses:
    BadRequest:
      description: Request validation failed
      content:
        application/json:
          schema:
            allOf:
              - $ref: '#/components/schemas/ErrorResponse'
              - type: object
                properties:
                  violations:
                    type: array
                    items:
                      type: object
                      properties:
                        propertyPath:
                          type: string
                        message:
                          type: string
                        code:
                          type: string
                    description: List of validation violations
            examples:
              invalid_email:
                value:
                  type: 'https://tools.ietf.org/html/rfc2616#section-10'
                  title: Validation Failed
                  detail: email must be a valid email address
                  status: 400
                  violations:
                    - propertyPath: email
                      message: This is not a valid email.
                      code: invalid_format

    Unauthorized:
      description: Authentication required or invalid credentials
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          example:
            type: 'https://tools.ietf.org/html/rfc2616#section-10'
            title: Unauthorized
            detail: Valid authentication credentials required
            status: 401

    Forbidden:
      description: Insufficient permissions
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          example:
            type: 'https://tools.ietf.org/html/rfc2616#section-10'
            title: Access Denied
            detail: You do not have permission to access this resource
            status: 403

    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          example:
            type: 'https://tools.ietf.org/html/rfc2616#section-10'
            title: Not Found
            detail: The requested workflow could not be found
            status: 404
```

### 2. Paginated List Responses

```yaml
components:
  responses:
    WorkflowList:
      description: Paginated list of workflows
      content:
        application/json:
          schema:
            type: object
            properties:
              data:
                type: array
                items:
                  $ref: '#/components/schemas/Workflow'
              meta:
                $ref: '#/components/schemas/PaginationMeta'
            required: [data, meta]
          example:
            data:
              - id: 123e4567-e89b-12d3-a456-426614174000
                name: Sales Agreement
                status: active
                workspaceId: 550e8400-e29b-41d4-a716-446655440000
                creatorId: 6ba7b810-9dad-11d1-80b4-00c04fd430c8
                createdAt: 2024-01-15T10:30:00Z
                updatedAt: 2024-01-15T14:22:00Z
            meta:
              page: 1
              limit: 20
              total: 45
              pages: 3
```

---

## Request Design

### 1. Reusable Parameters

```yaml
components:
  parameters:
    IdPath:
      name: id
      in: path
      required: true
      schema:
        type: string
        format: uuid
      description: The resource UUID

    PageParam:
      name: page
      in: query
      schema:
        type: integer
        minimum: 1
        default: 1
      description: Page number (starts at 1)

    LimitParam:
      name: limit
      in: query
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20
      description: Number of results per page

    SortParam:
      name: sort
      in: query
      schema:
        type: string
        enum: [name, created_at, updated_at]
        default: created_at
      description: Sort by field

    OrderParam:
      name: order
      in: query
      schema:
        type: string
        enum: [asc, desc]
        default: desc
      description: Sort order
```

### 2. Request Bodies with Examples

```yaml
paths:
  /workflows:
    post:
      requestBody:
        required: true
        description: Workflow creation details
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateWorkflowInput'
            examples:
              minimal:
                summary: Minimal workflow
                value:
                  name: Simple Process
                  workspaceId: 550e8400-e29b-41d4-a716-446655440000

              full:
                summary: Complete workflow
                value:
                  name: Complex Multi-Step Process
                  description: Comprehensive workflow with all optional fields
                  workspaceId: 550e8400-e29b-41d4-a716-446655440000
```

---

## Security and Authorization

### 1. Document All Auth Methods

```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        Authenticate using a Bearer token in the Authorization header.

        Example:
        ```
        Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
        ```

security:
  - BearerAuth: []

# Override security for specific endpoints
paths:
  /auth/login:
    post:
      security: []  # Public endpoint, no auth required
```

---

## Best Practices Checklist

When creating or reviewing an OpenAPI spec:

### Documentation
- [ ] Clear, descriptive `summary` for every endpoint (1-2 sentences)
- [ ] Detailed `description` explaining purpose and preconditions
- [ ] Every parameter has a `description`
- [ ] Every schema property has a `description`
- [ ] Examples for complex request/response bodies

### Structure
- [ ] All endpoints grouped under logical tags
- [ ] Consistent HTTP verb usage (GET, POST, PUT, DELETE, PATCH)
- [ ] Consistent URL patterns (e.g., `/resources/{id}` for single item)
- [ ] Consistent response status codes (201 for creation, 204 for deletion, etc.)
- [ ] All error responses documented (400, 401, 403, 404, 500)

### Type Safety
- [ ] Every field has explicit `type`
- [ ] All numeric fields have `minimum`/`maximum` or ranges
- [ ] All string fields have `minLength`/`maxLength` or patterns
- [ ] Enums used for finite value sets
- [ ] `required` arrays specify mandatory fields
- [ ] No `type: object` without properties defined

### Reusability
- [ ] Common schemas in `components/schemas`
- [ ] Reusable parameters in `components/parameters`
- [ ] Reusable responses in `components/responses`
- [ ] Use `$ref` to avoid duplication
- [ ] Use `allOf` for schema composition

### Consistency
- [ ] Error response format is consistent across all endpoints
- [ ] Pagination structure is consistent
- [ ] Timestamp format is consistent (ISO 8601)
- [ ] Status codes are consistent (same codes for same situations)
- [ ] Naming conventions consistent (camelCase, snake_case, etc.)

### Security
- [ ] Authentication method documented in `securitySchemes`
- [ ] All endpoints specify required security
- [ ] Permission requirements documented
- [ ] Rate limiting documented if applicable

### API Versioning
- [ ] Version in URL (`/v3/`) or header
- [ ] Breaking changes clearly documented
- [ ] Deprecation notices for old endpoints
- [ ] Migration guides for deprecated features

---

## Common Mistakes to Avoid

### ❌ Missing Descriptions
```yaml
# WRONG - No context
paths:
  /workflows/{id}:
    get:
      summary: Get workflow
      operationId: getWorkflow
```

### ✅ Clear Descriptions
```yaml
# GOOD - Self-documenting
paths:
  /workflows/{id}:
    get:
      summary: Retrieve a workflow
      description: |
        Fetches a workflow by ID with all associated metadata.

        The authenticated user must have read access to the workflow's workspace.
        For templates, the creator or organization admin can read.
      operationId: getWorkflow
```

---

### ❌ Inconsistent Error Responses
```yaml
# Different error formats
responses:
  '400':
    schema:
      properties:
        error: { type: string }

  '404':
    schema:
      properties:
        message: { type: string }
```

### ✅ Consistent Error Responses
```yaml
# All errors use same schema
responses:
  '400':
    $ref: '#/components/responses/ValidationError'

  '404':
    $ref: '#/components/responses/NotFound'
```

---

### ❌ Vague Schemas
```yaml
properties:
  data:
    type: object  # What's in this object?

  items:
    type: array   # Array of what?
```

### ✅ Precise Schemas
```yaml
properties:
  data:
    $ref: '#/components/schemas/Workflow'

  items:
    type: array
    items:
      $ref: '#/components/schemas/WorkflowSignature'
```

---

## Summary

High-quality OpenAPI specs are:

1. **Self-Documenting** - Readable without external docs
2. **Type-Safe** - Every field precisely defined
3. **Consistent** - Patterns repeated throughout
4. **Reusable** - Components shared where possible
5. **Clear** - Descriptions and examples for everything
6. **Validated** - Against best practices and tools

Following these patterns makes your API:
- **Easier to consume** for frontend/client developers
- **Easier to maintain** with consistent patterns
- **Self-validating** against the specification
- **Better documented** with generated documentation
- **More professional** and trustworthy
