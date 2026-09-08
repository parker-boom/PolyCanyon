#!/usr/bin/env python3
"""Dependency-free catalog/asset checks, runnable on macOS or Linux (including CI)."""
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IOS = ROOT / 'swift/Poly Canyon'
DATA = IOS / 'Core/Data'


def read(path):
    return json.loads(path.read_text())


def require(condition, message):
    if not condition:
        raise SystemExit('FAIL: ' + message)


structures = read(DATA / 'structuresList.json')
ghosts = read(DATA / 'ghostStructures.json')
points = read(DATA / 'mapPoints.json')
ids = [x['Number'] for x in structures] + [int(x['number']) for x in ghosts]
require(len(ids) == len(set(ids)), 'structure identities must be unique across both catalogs')
point_ids = [x['name'] for x in points]
require(len(point_ids) == len(set(point_ids)), 'map point identities must be unique')
for p in points:
    require(p['structure'] == -1 or p['structure'] in ids, f"unknown structure on map point {p['name']}")
    require(math.isfinite(p['latitude']) and -90 <= p['latitude'] <= 90, 'invalid latitude')
    require(math.isfinite(p['longitude']) and -180 <= p['longitude'] <= 180, 'invalid longitude')
    require(isinstance(p['pixelX'], int) and isinstance(p['pixelY'], int), 'map pixels must be integers')
assets = {p.stem for p in (IOS / 'Assets.xcassets').rglob('*.imageset')}
references = {image for entry in structures for image in entry['Images']}
references |= {image for entry in ghosts for image in entry['images']}
# These names are constructed from a base plus NN by both map views.
references |= {base + suffix for base in ['LightMap', 'DarkMap', 'SatelliteMap'] for suffix in ['', 'NN']}
require(references <= assets, 'missing iOS images: ' + ', '.join(sorted(references - assets)))
for descriptor in (IOS / 'Assets.xcassets').rglob('Contents.json'):
    for image in read(descriptor).get('images', []):
        if 'filename' in image:
            require((descriptor.parent / image['filename']).is_file(), f'missing asset file in {descriptor}')
print(f'PASS: {len(structures)} structures, {len(ghosts)} ghosts, {len(points)} map points and all iOS image references')
tagged = {p['structure'] for p in points if p['structure'] != -1}
print('Catalog entries without discovery coordinates:', sorted(set(ids) - tagged))

# Differences are reported, not automatically overwritten: platform image selections differ intentionally.
original = {x['Number']: x for x in read(ROOT / 'assets/data/structuresList.json')}
for label, path in [('iOS', DATA / 'structuresList.json'), ('Archived Android', ROOT / 'assets/retired-android/src/Core/Data/structuresList.json')]:
    catalog = {x['Number']: x for x in read(path)}
    differences = {str(n): sorted(k for k in set(original[n]) | set(catalog[n]) if original[n].get(k) != catalog[n].get(k))
                   for n in original.keys() & catalog.keys() if original[n] != catalog[n]}
    print(label + ' differences from assets/data:', json.dumps(differences, sort_keys=True))
    print(label + ' identity differences:', sorted(original.keys() ^ catalog.keys()))
for path in [DATA / 'mapPoints.json', ROOT / 'assets/retired-android/src/Core/Location/mapPoints.json', DATA / 'ghostStructures.json']:
    source = ROOT / 'assets/data' / path.name
    print(str(path.relative_to(ROOT)) + ': ' + ('matches assets/data' if read(path) == read(source) else 'DIFFERS from assets/data; review before syncing'))

# Retired content is deliberately retained outside the executable app; detect accidental loss.
archive_manifest = read(ROOT / 'assets/retired-android/preservation.json')
for entry in archive_manifest['files']:
    path = ROOT / entry['preserved']
    require(path.is_file(), 'missing preserved content: ' + entry['preserved'])
    require(hashlib.sha256(path.read_bytes()).hexdigest() == entry['sha256'],
            'preserved content changed: ' + entry['preserved'])
print(f"PASS: {len(archive_manifest['files'])} archived Android content files match their original checksums")
