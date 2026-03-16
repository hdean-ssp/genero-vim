# Bugfix Requirements Document

## Introduction

The autocompile feature (triggered on buffer entry and file save) applies only unused variable highlighting but is missing error and warning highlighting. The `:GeneroCompile` command correctly applies both types of highlighting. This inconsistency means users don't see error/warning highlights during autocompile, only when manually running `:GeneroCompile`. The fix ensures autocompile applies the exact same highlighting as the manual command.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a file is compiled via autocompile (on buffer enter or save) THEN the system applies only unused variable highlighting and skips error/warning highlighting

1.2 WHEN a file is compiled via autocompile THEN the system calls `genero_tools#compiler#highlight#unused_vars()` but does not call `genero_tools#compiler#highlight#apply()`

### Expected Behavior (Correct)

2.1 WHEN a file is compiled via autocompile (on buffer enter or save) THEN the system SHALL apply both error/warning highlighting AND unused variable highlighting

2.2 WHEN a file is compiled via autocompile THEN the system SHALL call both `genero_tools#compiler#highlight#apply()` for errors/warnings AND `genero_tools#compiler#highlight#unused_vars()` for unused variables

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a file is compiled via the `:GeneroCompile` command THEN the system SHALL CONTINUE TO apply both error/warning highlighting and unused variable highlighting

3.2 WHEN autocompile is disabled THEN the system SHALL CONTINUE TO not apply any highlighting on buffer enter or save

3.3 WHEN the `compiler_highlight_unused` config option is disabled THEN the system SHALL CONTINUE TO skip unused variable highlighting during autocompile

3.4 WHEN the `compiler_sign_column` config option is disabled THEN the system SHALL CONTINUE TO skip sign placement during autocompile

3.5 WHEN the `compiler_autocompile` config option is disabled THEN the system SHALL CONTINUE TO not trigger compilation on buffer enter or save
