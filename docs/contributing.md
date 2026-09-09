# Contributing and maintenance

Keep changes focused and preserve the reviewed exploration flow. The website has its own repository; coordinate shared content changes without copying its build system into the app.

## Change code

1. Make a focused branch from main.
2. Run the checks in [setup](setup.md).
3. For UI changes, review the affected flow in an iPhone Simulator, including navigation back out. Check both exploration modes if the change touches shared state. Respect Reduce Motion and accessibility labels.
4. Open a pull request describing the user-visible change and relevant verification. Merge after checks pass, then remove the completed branch.

Do not commit build output, signing identities, device-specific settings, or API credentials. The maintained app has no external package dependency; adding one should solve a concrete problem and include a license and privacy review.

## Change research or photos

The shipping catalogs are in `swift/Poly Canyon/Core/Data/`. Preserve structure numbers, source attributions, and original photographs. Search supports names, numbers, and years, so verify those fields when correcting a record.

Add a reviewed image export to the asset catalog, reference it in the appropriate catalog, and run `check-data.py`. Check both the thumbnail and full-screen presentation. Do not replace the iOS catalog wholesale with reference or retired Android data: their image selections differ intentionally.

Map changes require reviewing illustration pixels and geographic coordinates together, then running the map and location checks. Do not invent coordinates to silence a validation note.

See [data and privacy](data-and-privacy.md) for the source map and [media](media.md) for promotional captures. Refresh screenshots when a visible change makes them inaccurate.
