# Breaking changes diagnostics

This folder contains metadata required for `swift package diagnose-api-breaking-changes` tool:
- baseline.txt: contains the version of the package that is used as a baseline for detecting breaking changes.
- breakage-allowlist-path.txt: contains the list of breaking changes that we accepted to exist.

## The procedure of accepting breaking changes

1. Obtain the list of breaking changes from Circle CI "Breaking changes" job using "Artifacts" tab.
1. Add the list of breaking changes to `breakage-allowlist-path.txt` file removing the preceding emoji. For example, for generated breaking change line of `💔 API breakage: constructor Incident.init(identifier:type:description:creationDate:startDate:endDate:impact:subtype:subtypeDescription:alertCodes:lanesBlocked:shapeIndexRange:) has been removed` the following line should be added to `breakage-allowlist-path.txt`: `API breakage: constructor Incident.init(identifier:type:description:creationDate:startDate:endDate:impact:subtype:subtypeDescription:alertCodes:lanesBlocked:shapeIndexRange:) has been removed`

## Bumping baseline

### Script

- Run `scripts/update-baseline.sh <new_baseline_tag>` from the root of the repository. For example:
   ```bash
   $ ./scripts/update-baseline.sh v2.5.0-rc.1
   ```

- Commit the generated changes:
    - `baseline.txt`: contains the new baseline version.
    - `breakage-allowlist-path.txt`: contains the new list of breaking changes that we accepted to exist.

### Manual

- Change `baseline.txt` to the new version of the package.
- Clear `breakage-allowlist-path.txt` file.
- Commit the changed files.

