#!/usr/bin/env bash

# shellcheck disable=SC2016,SC2155

run_cleanup() {

  rm -f ".github/workflows/op-update-license.yml"
  rm -f ".github/workflows/update-copyright.yml"
  rm -f ".github/workflows/update-license.yml"
  rm -f "LICENSE"

}

set_commit() {

  git add .
  git diff --staged --quiet || git commit -m "chore: add LICENSE and workflow to bump copyright"
  git push -u origin main

}

set_license() {

  local account="$(gh api user --jq ".name")"
  local outfile="LICENSE.md"
  [[ ! -f "$outfile" ]] && {
    echo "MIT License"
    echo ""
    echo "Copyright (c) $(date +%Y) ${account}"
    echo ""
    echo "Permission is hereby granted, free of charge, to any person obtaining a copy"
    echo 'of this software and associated documentation files (the "Software"), to deal'
    echo "in the Software without restriction, including without limitation the rights"
    echo "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"
    echo "copies of the Software, and to permit persons to whom the Software is"
    echo "furnished to do so, subject to the following conditions:"
    echo ""
    echo "The above copyright notice and this permission notice shall be included in all"
    echo "copies or substantial portions of the Software."
    echo ""
    echo 'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR'
    echo "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
    echo "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
    echo "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
    echo "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
    echo "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"
    echo -n "SOFTWARE."
  } >"$outfile"

}

set_workflow() {

  local outfile=".github/workflows/op-update-copyright.yml"
  mkdir -p "$(dirname "$outfile")" && {
    echo 'name: "📙 : Update Copyright"'
    echo ''
    echo 'on:'
    echo '  schedule:'
    echo '    - cron: "0 0 1 1 *"'
    echo '  workflow_dispatch:'
    echo ''
    echo 'permissions:'
    echo '  contents: write'
    echo ''
    echo 'jobs:'
    echo '  update:'
    echo '    runs-on: ubuntu-latest'
    echo '    steps:'
    echo '      - uses: actions/checkout@v4'
    echo '      - uses: actions/github-script@v7'
    echo '        with:'
    echo '          script: |'
    echo '            const fs = require("node:fs");'
    echo '            const year = new Date().getFullYear();'
    echo '            let content = fs.readFileSync("LICENSE.md", "utf8");'
    echo '            const pattern = /(Copyright\s+\(c\)\s+)(\d{4})(-\d{4})?/;'
    echo '            content = content.replace(pattern, (_, prefix, start, end) => {'
    echo '              const startYear = Number(start);'
    echo '              const endYear = end ? Number(end) : null;'
    echo '              const alreadyUpToDate = startYear === year || endYear === year;'
    echo '              return alreadyUpToDate ? `${prefix}${start}${end ? `-${end}` : ""}` : `${prefix}${startYear}-${year}`;'
    echo '            });'
    echo '            fs.writeFileSync("LICENSE.md", content);'
    echo '      - run: |'
    echo '          git config user.name "github-actions[bot]"'
    echo '          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"'
    echo '          git add LICENSE.md'
    echo '          git diff --staged --quiet || git commit -m "chore: bump copyright year to $(date +%Y)"'
    echo -n '          git push'
  } >"$outfile"

}

main() {

  run_cleanup
  set_license
  set_workflow
  set_commit

}

main "$@"