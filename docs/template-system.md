# Context Template System - Design Document

## Table of Contents
- [Motivation](#motivation)
- [System Overview](#system-overview)
- [Template Syntax](#template-syntax)
- [Formal Language Definition](#formal-language-definition)
- [Implementation Architecture](#implementation-architecture)
- [User Interfaces](#user-interfaces)
- [Agent Integration](#agent-integration)
- [Examples](#examples)

## Motivation

### The Problem
Modern AI assistants and agents need to work with complex, repetitive prompts that often share common patterns. Current solutions have limitations:

- **Copy-paste fatigue**: Users repeatedly write similar prompts
- **No reusability**: Agents can't leverage proven prompt patterns
- **Context loss**: Important project details must be manually included each time
- **No composition**: Can't build complex prompts from simpler parts
- **Rigid structure**: No conditional logic or dynamic content

## Benefits

- **Consistency**: Standardized approaches across team
- **Efficiency**: No more rewriting common prompts
- **Evolution**: Templates improve over time
- **Collaboration**: Agents and humans share knowledge
- **Context Preservation**: Never lose project details
- **Composability**: Build complex workflows from simple parts
- **Discoverability**: Easy to find and use existing patterns

### The Solution
A template system inspired by email clients like Notion that extends the concept for AI interactions:

- **Recursive composition**: Templates can include other templates
- **Parameterized**: Templates accept arguments, some auto-filled from context
- **Universal access**: Both humans and agents can use templates
- **Dynamic management**: Templates can be created, modified, and deleted on the fly
- **Context-aware**: Automatically includes relevant project information

## Template Examples

Let's start with practical examples to understand how the template system works, from simple to complex:

### 1. Simple Variable Substitution

```
Hi, I'm {user_name} working on {project_name} and need help with {task}.

Please provide guidance on best practices and implementation steps.
```
*Simple template with variable placeholders. Variables like `{user_name}` and `{project_name}` are auto-filled from context, while `{task}` comes from user arguments.*

**Usage:** `/intro{task: "user authentication"}`

### 2. Nested Templates

```
Create a new feature called {name} for {project_name}.

Tech stack: {tech_stack}

/coding_standards
/test_requirements{coverage: 80}
/generate_documentation{feature: {name}}
```
*Introduces **nested templates** with `/template_name` syntax. Templates can call other templates, creating reusable building blocks that can be composed together.*

**Usage:** `/build_feature{name: "user auth"}`

**Referenced Templates:**

`coding_standards` template:
```
## Code Quality Standards

- Follow ESLint configuration
- Use TypeScript for type safety
- Write self-documenting code with clear variable names
- Add JSDoc comments for all public functions
- Maintain 100% test coverage for critical paths
```

`test_requirements` template:
```
## Testing Requirements

- Unit tests for all business logic
- Integration tests for API endpoints
- Target coverage: {coverage}%
- Use Jest for testing framework
- Mock external dependencies
- Include edge case testing
```

`generate_documentation` template:
```
## Documentation for {feature}

Please create:
- README with setup instructions
- API documentation if applicable
- Code examples and usage patterns
- Troubleshooting guide
- Deployment notes
```

### 3. Conditional Logic

```
Create a new feature called "{name}" for {project_name}.

\if {type} == "oauth"
  Implementation type: OAuth 2.0 authentication
  Required dependencies: passport, passport-oauth2
\elif {type} == "jwt"
  Implementation type: JWT token-based authentication
  Required dependencies: jsonwebtoken, bcrypt
\else
  Implementation type: standard session-based authentication
  Required dependencies: express-session
\endif

Tech stack: {tech_stack}

/coding_standards
/test_requirements{coverage: 80}
```
*Introduces **conditional logic** with `\if`, `\elif`, `\else`, `\endif` and **comparison operators**. The backslash prefix distinguishes control structures from JSON objects.*

**Usage:** `/build_feature{name: "user auth", type: "oauth"}`

### Key Concepts Summary

- **Variables**: `{variable}` - Replaced with values from arguments or context
- **Conditionals**: `\if`, `\elif`, `\else`, `\endif` - Control flow logic
- **Nested templates**: `/template_name{args}` - Compose templates together
- **Context variables**: Auto-filled from current project (e.g., `{project_name}`, `{tech_stack}`)

```mermaid
flowchart LR
    A[User Input<br/>/template{args}] --> B[Template Engine]
    B --> C[Parse & Validate]
    C --> D[Load Template]
    D --> E[Resolve Nested Templates]
    E --> F[Interpolate Variables]
    F --> G[Process Control Structures]
    G --> H[Expanded Text]
    H --> I[Human/Agent]
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style H fill:#e8f5e8
    style I fill:#fff3e0
```

## Formal Language Definition

### BNF Grammar
```bnf
<template-invocation> ::= "/" <identifier> <arguments>?
<arguments>           ::= "{" <arg-list>? "}"
<arg-list>            ::= <arg> ("," <arg>)*
<arg>                 ::= <identifier> ":" <value>
<value>               ::= <string> | <number> | <boolean> | <identifier>

<template-definition> ::= <body>
<body>                ::= (<text> | <expression> | <control-structure>)*

<expression>          ::= "{" <variable-ref> "}"
<variable-ref>        ::= <identifier> <property-access>*
<property-access>     ::= "." <identifier>

<control-structure>   ::= <if-block> | <include>
<if-block>            ::= "\\if" <condition> <body> <elif-block>* <else-block>? "\\endif"
<elif-block>          ::= "\\elif" <condition> <body>
<else-block>          ::= "\\else" <body>
<condition>           ::= <expression> <operator> <value>
<operator>            ::= "==" | "!="

<include>             ::= "/" <identifier> <arguments>?
```



### Keywords and Operators

#### Control Flow
- `\if`, `\elif`, `\else`, `\endif` - Conditional blocks

#### Operators
- `==`, `!=` - Equality/inequality



### Lexical Elements
```
IDENTIFIER     = [a-zA-Z_][a-zA-Z0-9_]*
STRING         = '"' [^"]* '"' | "'" [^']* "'"
NUMBER         = [0-9]+ ("." [0-9]+)?
BOOLEAN        = "true" | "false"
TEMPLATE_START = "/"
ARG_OPEN       = "{"
ARG_CLOSE      = "}"
DOT            = "."
COLON          = ":"
COMMA          = ","
BACKSLASH      = "\\"
```

## Implementation Architecture

### Template Definition Schema
Templates are just text files with placeholders. No metadata needed - everything is inferred:

```
Create a new feature called "{name}" for {project_name}.
\if {type} == "oauth"
  Implementation type: OAuth 2.0 authentication
\elif {type} == "jwt"  
  Implementation type: JWT token-based authentication
\else
  Implementation type: standard session-based authentication
\endif
Tech stack: {tech_stack}

/coding_standards
/test_requirements{coverage: 80}
```

That's it! The system automatically:
- **Discovers arguments** by parsing `{variable}` patterns
- **Infers types** from usage (string by default, number/boolean from context)
- **Auto-fills context** variables like `{project_name}`, `{tech_stack}` from current project


## Additional Examples

### Template with Multiple Modules
File: `templates/project_setup.txt`
```
Setting up project with modules:

/setup_module{name: "auth", deps: "bcrypt,jwt"}
/setup_module{name: "database", deps: "mongoose"}
/setup_module{name: "api", deps: "express,cors"}
```

Usage: `/project_setup`

### Template with Logic
File: `templates/create_component.txt`
```
Create a {type} component named {name}.

\if {type} == "form"
  /form_validation_rules
\elif {type} == "list"
  /pagination_setup
\else
  /basic_component_setup
\endif
```

### Quick Code Review Template
File: `templates/code_review.txt`
```
Please review this {language} code for:

\if {focus_areas}
Focus areas: {focus_areas}
\else
- Code quality and best practices
- Security vulnerabilities
- Performance issues
- Testing coverage
\endif

\if {context}
Context: {context}
\endif

/analyze_code{
  language: {language},
  focus: {focus_areas}
}
```

Usage:
```
/code_review{
  language: "JavaScript",
  focus_areas: "security, performance",
  context: "This is a payment processing module"
}
```

### Template Composition
File: `templates/custom_feature.txt`
```
/build_feature{name: {name}, type: {type}}

Additional requirements:
/company_specific_rules
```

### Complex Real-World Example
File: `templates/create_api_endpoint.txt`
```
Creating API endpoint for {resource} resource in {project_name}.

API Version: {api_version}
Methods: {methods}

\if {auth_required}
  /setup_auth_middleware{resource: {resource}}
\endif

/create_get_handler{
  resource: {resource},
  pagination: true,
  filtering: true
}

/create_post_handler{
  resource: {resource},
  validation: /validation_rules{resource: {resource}}
}

/create_put_handler{
  resource: {resource},
  partial_update: true
}

/create_delete_handler{
  resource: {resource},
  soft_delete: true
}

\if {database_type} == "sql"
  /sql_migrations{resource: {resource}}
\else
  /nosql_schema{resource: {resource}}
\endif

/generate_tests{
  resource: {resource},
  methods: {methods},
  coverage_target: 90
}

/update_api_documentation{
  resource: {resource},
  version: {api_version}
}
```

Usage:
```
/create_api_endpoint{
  resource: "users",
  methods: "GET, POST, PUT, DELETE",
  auth_required: true
}
```

## Agent Integration

### MCP Function Calls

#### Template Discovery and Listing
```javascript
// List all available templates
const templates = await mcp.call('list_templates', {
  category?: 'development' | 'testing' | 'documentation' | 'debugging',
  search?: 'auth',           // Search by name or description
  tags?: ['api', 'security'] // Filter by tags
});
// Returns: { templates: [{ name, description, category, tags, created, modified }] }

// Get detailed template information
const template = await mcp.call('get_template', {
  name: 'build_feature'
});
// Returns: { 
//   name, body, category, tags, description,
//   variables: ['name', 'type'],        // Discovered from {variable} patterns
//   nested_templates: ['coding_standards'], // Discovered from /template patterns
//   context_variables: ['project_name', 'tech_stack'], // Auto-filled variables
//   created, modified
// }
```

#### Template Expansion and Execution
```javascript
// Expand a template with arguments
const result = await mcp.call('expand_template', {
  name: 'build_feature',
  args: {
    name: 'shopping_cart',
    type: 'complex'
  },
  context?: {              // Override auto-detected context
    project_name: 'my-app',
    tech_stack: 'React/Node.js'
  }
});
// Returns: { expanded_text: '...', variables_used: {...}, nested_templates_expanded: [...] }

// Dry-run template expansion (validate without executing)
const validation = await mcp.call('validate_template', {
  name: 'build_feature',
  args: {
    name: 'shopping_cart',
    type: 'complex'
  }
});
// Returns: { 
//   valid: true, 
//   missing_variables: [], 
//   unknown_nested_templates: [],
//   warnings: ['Variable {optional_var} not provided, will be empty']
// }
```

#### Template Management (CRUD)
```javascript
// Create a new template
await mcp.call('create_template', {
  name: 'debug_issue',
  body: 'Debug this error: {error_message}\nContext: {context}\n/review_logs',
  category?: 'debugging',
  tags?: ['error', 'troubleshooting'],
  description?: 'Template for debugging issues with context'
});

// Update an existing template
await mcp.call('update_template', {
  name: 'debug_issue',
  body?: 'Updated template body...',
  category?: 'debugging',
  tags?: ['error', 'troubleshooting', 'logs'],
  description?: 'Updated description'
});

// Delete a template
await mcp.call('delete_template', {
  name: 'debug_issue'
});

// Check if template exists
const exists = await mcp.call('template_exists', {
  name: 'debug_issue'
});
// Returns: { exists: true }
```

#### Template Analysis and Introspection
```javascript
// Analyze template dependencies
const analysis = await mcp.call('analyze_template', {
  name: 'build_feature'
});
// Returns: {
//   variables: {
//     required: ['name'],
//     optional: ['type'],
//     context: ['project_name', 'tech_stack']
//   },
//   nested_templates: ['coding_standards', 'test_requirements'],
//   dependency_tree: { ... },
//   circular_dependencies: [],
//   complexity_score: 3.2
// }

// Get template usage statistics
const stats = await mcp.call('get_template_stats', {
  name: 'build_feature',
  period?: '30d'
});
// Returns: { usage_count: 42, last_used: '2024-01-15', avg_args: {...} }
```

#### Context Management
```javascript
// Get current context variables
const context = await mcp.call('get_context');
// Returns: { project_name: 'my-app', tech_stack: 'React/Node.js', user_name: 'john', ... }

// Set context variables
await mcp.call('set_context', {
  project_name: 'new-project',
  tech_stack: 'Vue/Express',
  custom_var: 'value'
});

// Clear specific context variables
await mcp.call('clear_context', {
  variables: ['custom_var']
});
```

#### Batch Operations
```javascript
// Expand multiple templates in sequence
const results = await mcp.call('expand_templates_batch', {
  templates: [
    { name: 'setup_project', args: { name: 'my-app' } },
    { name: 'create_readme', args: { project: 'my-app' } },
    { name: 'setup_ci', args: { platform: 'github' } }
  ]
});
// Returns: { results: [{ template: 'setup_project', expanded_text: '...' }, ...] }

### Direct Template Usage in Agent Messages
```
Agent: I'll create the authentication system using our standard template:

/build_feature{
  name: "authentication",
  type: "oauth2",
  providers: "google, github"
}
```