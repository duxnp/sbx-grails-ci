# RIMS Copilot Instructions

## Project Overview

A Grails 7 web application following the Model-View-Controller (MVC)
architectural pattern. It is used for managing organizational hierarchies, user positions, and administrative requests
at Rowan University. It integrates with Banner (university ERP), Active Directory, and CAS single sign-on.

## Root Folders

- **grails-app/**: Main Grails application structure
- **src/**: Additional source code
- **bin/**: Build output and test resources
- **build/**: Compiled output (generated during build)
- **gradle/**: Gradle wrapper files

## Core Application Structure (grails-app/ folder)

The grails-app/ directory follows Grails convention-over-configuration architecture:

- **grails-app/assets/**: Frontend assets (compiled via asset-pipeline)
  - **images/**: Image assets
  - **javascripts/**: Custom JavaScript code
  - **lib/**: Third-party JS/CSS libraries
  - **stylesheets/**: CSS styles
- **grails-app/conf/**: Configuration and security
  - **spring/**: Spring Boot DSL bean definitions
  - **application.yml**: Database, CAS, mail, logging config
- **grails-app/controllers/**: HTTP request handlers
- **grails-app/domain/**: GORM domain classes representing the data model
- **grails-app/i18n/**: Internationalization message bundles
- **grails-app/init/**: Bootstrap code run at application startup
- **grails-app/services/**: Transactional business logic layer
- **grails-app/taglib/**: Tag Libraries providing reusable view helpers
- **grails-app/views/**: GSP (Groovy Server Pages) templates
  - **layout/**: Main Sitemesh 2 layout templates
  - **templates/**: Reusable GSP fragments
  - All other subfolders correspond to controllers following the convention in which the folder name corresponds to the
    controller name and the view GSP filenames within those folders match controller action names.

The architecture follows these principles:

- **Convention over configuration**: File location determines behavior
- **Service layer transactions**: All services use `@Transactional`
- **Domain-driven design**: Rich domain objects with GORM persistence
- **MVC separation**: Controllers delegate to services, services manipulate domains

## Source Structure (src/ folder)

- **src/integration-test/**: Functional (browser automation) and integration tests
  - **integration-test/groovy/\*/browserautomation**: Geb browser-based functional tests against running application
  - **integration-test/groovy/\*/integration**: Integration tests with full access to the Grails environment
- **src/main/groovy/**: Supporting Groovy classes
  - **rims/AppUserPasswordEncoderListener**: GORM event listener for password hashing
  - Utility classes and custom types
- **src/test/groovy/\*/**: Unit tests (Spock framework)
  - **BaseSpec.groovy**: Base test class with security principal mocking
  - Subfolders here mirror the folder names of subfolders within `grails-app/`; e.g., `src/test/groovy/*/services/`
    contains unit tests for service classes.
  - Test classes in each subfolder correspond to the classes in the main source folder with the same name plus the
    `Spec` suffix; e.g., `PositionService.groovy` is tested by `PositionServiceSpec.groovy`.

## Development Workflows

### Build & Test

```bash
# Run all tests (unit + integration)
./gradlew check --info

# Unit tests only
./gradlew test --info

# Integration tests only
./gradlew integrationTest --info

# Dev server (hot reload via DevTools)
./gradlew bootRun --info
```

- Use `--info` or `--debug` flags for detailed logging; the more detailed output assists in diagnosing issues.

## Code Patterns & Conventions

### Domain Classes

- **Constraints**: Always define `static constraints { }` block with validation rules
- **Mapping**: Always define `static mapping { }` with generator, comments, fetch strategies
- **Transient**: Mark injected services as `transient` to exclude from persistence
- **Relationships**: Use `hasOne`, `hasMany`, and `belongsTo`; define `mappedBy` to prevent bi-directional confusion
- **Auditable**: Implement `Auditable` for auto-tracking changes via auditable plugin

### Services

- **@Transactional**: Service classes that persist data to a database must use this annotation
- **Dependency injection**: Use groovy properties `RequestService requestService` for auto-injection

### GORM Queries

- Use .get() to retrieve a record by primary key
  - `Position.get(id)`
- Use dynamic finders ONLY when there is a single criterion
  - `Position.findAllByUser(user)`
- Use where queries when two or more criteria are required
  - `Position.where{ user.displayName =~ "%${term}%" && primarySupervisor == currPosition}`
- Fetch eager joins in mappings when N+1 issues are likely
- Avoid manual session management; @Transactional handles it

## Testing Approach

### Unit Tests (Spock)

- New tests added to an existing `*Spec.groovy` file must placed within the class; simply appending them to the file
  will not work.
- Extend `BaseSpec` if any of the utility methods in rims.BaseSpec are needed
- Method names describe behavior: `void "add user to organization"() { }`
- Use Builder pattern for test data if it improves readability in the test:
  `new OrganizationBuilder().withFunctional().build().save()`
- Use `mockDomains(...)` to mock multiple domain classes in unit tests (or `mockDomain(...)` for a single domain), and
  specify `failOnError: true` when saving instances to catch validation issues immediately
- Place test data creation in `setup()` method when possible to reduce duplication across tests
- Run tests after creating them to validate implementation and catch issues early
- **Stub**: Stub() is used to make collaborators respond to method calls in a certain way. When stubbing a method, you
  don’t care if and how many times the method is going to be called; you just want it to return some value, or perform
  some side effect, whenever it gets called.
- **Mock**: Mock() is used to describe interactions between the object under specification and its collaborators. Avoid
  using Mock() if Stub() is sufficient.
- **Spy**: Spy() is always based on a real object with original methods that do real things. Can be used like a Stub to
  change return values of select methods. Can be used like a Mock to describe interactions. Avoid using Spy() if Mock()
  is sufficient.

#### Stub vs Mock vs Spy

- A Stub() is a Stub.
- A Mock() is a Stub and Mock.
- A Spy() is a Stub, Mock, and Spy.
- GroovyStub(), GroovyMock(), or GroovySpy() must be used when the code under specification is written in Groovy and
  some of the unique Groovy mock features are needed.

### Functional Tests (Geb) a.k.a. Browser Automation

- **src/seed/test/**: Grails SeedMe plugin seed files for the test environment database.
- **src/integration-test/groovy/\*/browserautomation**: Geb tests that run against a running instance of the
  application, simulating user interactions with the browser. These tests are ideal for verifying client-side
  functionality and user experience.
- **src/integration-test/groovy/\*/browserautomation/modules**: Reusable modules representing components or sections
  of a web page, allowing for modular and maintainable Geb tests. Geb modules correspond to partial GSP templates in
  `grails-app/views/templates/` that are included in multiple pages.
- **src/integration-test/groovy/\*/browserautomation/pages**: Page objects representing the structure and behavior of
  the application's web pages. These classes encapsulate the locators and interactions for specific pages, promoting
  reuse and maintainability in Geb tests. Geb page objects correspond to GSP templates in `grails-app/views/` (besides
  the `layouts` and `templates` folders) that represent full pages (not partial templates). Geb modules can be used
  within Geb page objects to represent reusable components on those pages.
- **src/integration-test/groovy/\*/browserautomation/utils**: Utility classes and helper methods for Geb tests,
  providing common functionality and reducing code duplication.

## Commit Messages

- Use [Conventional Commits](https://www.conventionalcommits.org/) format: `<type>(<scope>): <description>`
- Valid types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`, `perf`

### Commit Types

| Type       | When to Use                                                                                                                                             |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `feat`     | Introducing a new feature or capability visible to users or consumers of the API (e.g., new controller action, new domain class, new UI component)      |
| `fix`      | Correcting a bug or unintended behavior in existing code (e.g., fixing a validation rule, correcting a broken query, resolving a UI defect)             |
| `refactor` | Restructuring existing code without changing its external behavior (e.g., extracting a method, renaming a variable for clarity, reorganizing a service) |
| `test`     | Adding or updating tests with no production code changes (e.g., new Spock specs, updating Geb page objects, adding integration test coverage)           |
| `docs`     | Changes to documentation only (e.g., updating README, adding inline comments, revising copilot instructions)                                            |
| `chore`    | Routine maintenance tasks that don't affect production code or tests (e.g., updating dependencies, modifying `.gitignore`, adjusting project config)    |
| `ci`       | Changes to CI/CD pipeline configuration (e.g., modifying GitHub Actions workflows, updating Dockerfile, adjusting build scripts)                        |
| `perf`     | Changes that improve performance without altering behavior (e.g., adding eager fetching to a GORM mapping, optimizing a query, caching a result)        |

- Use scope to indicate the area of the codebase (e.g., `models`, `interfaces`, `services`, `deps`, `tests`)
- Write the subject line in imperative mood, lowercase, and keep it under 72 characters
- Do not end the subject line with a period
- Reference related GitHub issues in the footer when applicable (e.g., `Closes #50')
- If a commit introduces a breaking change, include `BREAKING CHANGE:` in the footer
- Use Markdown formatting in the commit message body for clarity when needed (e.g., code snippets, lists)

### Examples

```
feat(api): add person controller methods

fix(tests): correct expected value in password complexity tests

refactor(infrastructure): update person view

chore: update NuGet package dependencies
```

## Additional Resources

- [Grails 7 Documentation](https://grails.apache.org/docs/latest/)
- [GORM Documentation](https://grails.apache.org/docs/latest/grails-data/hibernate5/manual/index.html)
- [Spock Testing Framework](https://spockframework.org/spock/docs/2.4/all_in_one.html)
- [Geb Browser Automation](https://groovy.apache.org/geb/manual/current/)
