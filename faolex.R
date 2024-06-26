# Extracting number of relevant regulations from https://www.nature.com/articles/s41893-020-0577-7#Sec18
# The authors of the paper stored the data in a Google Sheet: https://docs.google.com/spreadsheets/d/1hOfl5Np80oC4EXrNMi7emnhx3RByRFSvOfEr9f2GJC4/edit#gid=0

library(tidyverse)
library(ggthemr)

results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)

# Load data ---------------------------------------------------------------
url <- "https://docs.google.com/spreadsheets/d/1hOfl5Np80oC4EXrNMi7emnhx3RByRFSvOfEr9f2GJC4/export?format=csv"
regulations <- readr::read_csv(url)
names(regulations)

count <- regulations %>%
  dplyr::select(country=Country,
           descriptors=Descriptors,
           sector=Sector,
           scale=Scale) %>%
  filter(grepl("fertili", descriptors, ignore.case = TRUE),
         grepl("national", scale, ignore.case = TRUE),
         grepl("agriculture", sector, ignore.case = TRUE)) %>%
  group_by(country) %>%
  summarise(count=n()) %>%
  arrange(desc(count))

# Export ------------------------------------------------------------------
ggthemr("dust")

count %>%
  head(20) %>%
  ggplot() +
  geom_bar(aes(count, reorder(country, count)), stat = "identity") +
  geom_text(aes(count, reorder(country, count), label=count), hjust=-0.2, nudge_x = 0.8, size=3) +
  scale_x_continuous(expand=expansion(mult=c(0, 0.05))) +
  labs(title="Number of national regulations on fertiliser use in agriculture",
       x="Number of regulations",
       subtitle="Top 20 countries",
       y=NULL,
       caption="Source: Kanter et al. Gaps and opportunities in nitrogen pollution policies around the world.\nNat Sustain 3, 956–963 (2020)")

ggsave(file.path(results_dir, "regulations.png"), width=8, height=5, scale=1.2)


count %>%
  dplyr::select(country, n_regulations=count) %>%
  clipr::write_clip() %>%
  write_csv(file.path(results_dir, "regulations.csv"))
