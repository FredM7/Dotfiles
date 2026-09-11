#!/usr/bin/env bash
# Review-queue fetch for the Quickshell Github module.
# Auth is entirely via `gh`. Never prints tokens.
set -euo pipefail

TEAM_SLUG="${GH_REVIEW_TEAM:-doshexchange/reviewers}"
LIMIT="${GH_REVIEW_LIMIT:-50}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    printf '{"ok":false,"error":"missing command: %s"}\n' "$1"
    exit 0
  }
}

need gh
need jq

if ! gh auth status -h github.com >/dev/null 2>&1; then
  printf '{"ok":false,"error":"gh is not logged in. Run: gh auth login"}\n'
  exit 0
fi

QUERY='query {
  viewer { login }
  search(query: "is:pr is:open review-requested:@me archived:false", type: ISSUE, first: '"${LIMIT}"') {
    issueCount
    nodes {
      ... on PullRequest {
        number
        title
        url
        isDraft
        updatedAt
        reviewDecision
        author { login }
        repository { nameWithOwner }
        headRefName
        baseRefName
        reviewRequests(first: 20) {
          nodes {
            requestedReviewer {
              __typename
              ... on User { login }
              ... on Team { slug combinedSlug }
            }
          }
        }
      }
    }
  }
}'

if ! raw="$(GH_PAGER=cat gh api graphql -f query="${QUERY}" 2>/tmp/gh-reviews.err)"; then
  printf '{"ok":false,"error":%s}\n' "$(jq -Rs . </tmp/gh-reviews.err)"
  exit 0
fi

jq -c --arg team "$TEAM_SLUG" '
  if (.data | not) or (.errors != null and ((.data.search.nodes // []) | length) == 0) then
    {
      ok: false,
      error: ((.errors[0].message) // .message // "graphql error")
    }
  else
    .data as $d
    | ($d.viewer.login // "") as $login
    | ($team | ascii_downcase) as $team
    | [
        ($d.search.nodes // [])[]
        | select(.url != null)
        | . as $pr
        | [
            ($pr.reviewRequests.nodes // [])[]
            | .requestedReviewer
            | select(. != null)
            | if .__typename == "Team" then (.combinedSlug // .slug // "")
              else (.login // "")
              end
          ] as $reviewers
        | {
            number: $pr.number,
            title: ($pr.title // ""),
            url: $pr.url,
            repo: ($pr.repository.nameWithOwner // ""),
            author: ($pr.author.login // ""),
            head: ($pr.headRefName // ""),
            base: ($pr.baseRefName // ""),
            isDraft: ($pr.isDraft // false),
            updatedAt: ($pr.updatedAt // ""),
            reviewDecision: ($pr.reviewDecision // ""),
            reviewers: $reviewers,
            personal: (
              $reviewers
              | map(ascii_downcase)
              | index($login | ascii_downcase) != null
            ),
            team: (
              $reviewers
              | map(ascii_downcase)
              | any(. == $team or endswith("/" + ($team | split("/")[-1])) )
            )
          }
      ] as $prs
    | {
        ok: true,
        login: $login,
        team: $team,
        count: ($d.search.issueCount // ($prs | length)),
        prs: $prs
      }
  end
' <<<"$raw"