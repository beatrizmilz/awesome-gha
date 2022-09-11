print("Hi! Welcome to a GH Actions with an R example :)")

# main script ------------------------------

# get information about the repositories on the Quarto organizations.

quarto_orgs <- c("quarto-dev", "quarto-ext", "quarto-journals")

quarto_repos_raw <-
  purrr::map(quarto_orgs, ~ gh::gh(
  "GET /orgs/{org}/repos",
  org = .x,
  type = "public",
  sort = "updated",
  per_page = 100
))


# transform into a tibble with few cols
quarto_repos <- quarto_repos_raw |>
  purrr::flatten() |>
  purrr::map(unlist, recursive = TRUE)  |>
  purrr::map_dfr(tibble::enframe, .id = "id_repo") |>
  tidyr::pivot_wider() |>
  dplyr::transmute(
    name,
    url = html_url,
    description,
    stars = as.numeric(stargazers_count),
    forks = as.numeric(forks_count),
    open_issues = as.numeric(open_issues_count)
  ) |>
  dplyr::arrange(dplyr::desc(stars))


# write CSV file with the result
quarto_repos |>
  readr::write_csv("01-monitoring-quarto-repos/quarto_repos.csv")

# write the README.md file

# create table to add on README
table <- quarto_repos |>
  dplyr::mutate(description = tidyr::replace_na(description, "")) |>
  knitr::kable()

# Write the content on README
paste0(
  "# Repositories from quarto-dev
Made by [Bea Milz](https://twitter.com/beamilz).
Updated with GitHub Actions in ",
format(Sys.Date(), '%b %d %Y'),
".
<hr> \n
",
paste(table, collapse = "\n")
) |> writeLines("01-monitoring-quarto-repos/README.md")

print("The end! Congrats!")
