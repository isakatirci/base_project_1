---
description: Build the project with Maven and report results
---
## Build Output
!`mvn clean verify 2>&1 | tail -50`

## Build Analysis
Analyze the build output above. Report:

1. **Build Status**: SUCCESS or FAILURE for each module
2. **Failed Modules**: Root cause analysis for any failures
3. **Test Results**: Summary of tests run, passed, failed, skipped
4. **Dependency Issues**: Any version conflicts or missing dependencies
5. **Recommendations**: Specific fixes for any failures

If the build succeeded, confirm all 8 modules built successfully:
- api, util
- product-service, recommendation-service, review-service, product-composite-service
- gateway, authorization-server
