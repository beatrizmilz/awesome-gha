print("Hi! Welcome to a GH Actions with an R example :)")

# Install the packages that are used in the script -------

install.packages("gh")
install.packages("dplyr")
install.packages("tidyr")
install.packages("readr")
install.packages("knitr")

# main script ------------------------------

# get information about the repositories on the Quarto-dev organization.
quarto_repos_raw <- gh::gh(
  "GET /orgs/{org}/repos",
  org = "quarto-dev",
  type = "public",
  sort = "updated",
  per_page = 100
)

# transform into a tibble with few cols
quarto_repos <- quarto_repos_raw |>
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
  readr::write_csv("01-rscript/quarto_repos.csv")

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
) |> writeLines("01-rscript/README.md")

print("The end! Congrats!")
