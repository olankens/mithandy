# MITHANDY

<p><img src=".assets/asset-01.png" align="center" width="100%"></p>

Bash script generating a LICENSE file and a GitHub Actions workflow scheduled to automatically bump the copyright year every January 1st, then commit and push with no pull request or human review needed.

## Launch Script

```sh
curl -fsSL https://raw.githubusercontent.com/olankens/mithandy/HEAD/scripts/mithandy.sh | bash
```