context("set_attributes")


test_that("we can have numeric data with bounds
          where some bounds are missing",
          {
            df <- data.frame(
              attributeName = "svl",
              attributeDefinition = "Snout-vent length",
              unit = "meter",
              numberType = "real",
              minimum = "0",
              maximum = NA,
              stringsAsFactors = FALSE
            )
            attributeList <-
              set_attributes(df, col_classes = "numeric")

            dataTable <- list(
              attributeList = attributeList,
              entityName = "file.csv",
              entityDescription = "csv file containing the data",
              physical = set_physical("file.csv")
            )

            me <-
              list(individualName =
                     list(givenName = "Carl",
                          surName = "Boettiger"))

            dataset <-
              list(
                title = "Example EML",
                creator = me,
                contact = me,
                dataTable = dataTable
              )
            eml <-
              list(packageId = "123",
                   system = "uuid",
                   dataset = dataset)

            write_eml(eml, "eml.xml")
            expect_true(eml_validate("eml.xml"))

          })

test_that("The set_attributes function
          works for the vignette example", {
            attributes <-
              data.frame(
                attributeName = c(
                  "run.num",
                  "year",
                  "day",
                  "hour.min",
                  "i.flag",
                  "variable",
                  "value.i",
                  "length"
                ),
                formatString = c(NA,
                                 "YYYY",
                                 "DDD",
                                 "hhmm",
                                 NA,
                                 NA,
                                 NA,
                                 NA),
                definition = c("which run number",
                               NA,
                               NA,
                               NA,
                               NA,
                               NA,
                               NA,
                               NA),
                unit = c(NA,
                         NA,
                         NA,
                         NA,
                         NA,
                         NA,
                         NA,
                         "meter"),
                attributeDefinition = c(
          "which run number (=block). Range: 1 - 6. (integer)",
          "year, 2012",
          "Julian day. Range: 170 - 209.",
          "hour and minute of observation. Range 1 - 2400 (integer)",
          "is variable Real, Interpolated or Bad (character/factor)",
          "what variable being measured in what treatment (character/factor).",
          "value of measured variable for run.num on year/day/hour.min.",
          "length of the species in meters (dummy example of numeric data)"
                ),
                numberType = c(NA,
                               NA,
                               NA,
                               NA,
                               NA,
                               NA,
                               NA,
                               "real"),
                stringsAsFactors = FALSE
              )
            i.flag <- c(R = "real",
                        I = "interpolated",
                        B = "bad")
            variable <- c(
              control  = "no prey added",
              low      = "0.125 mg prey added ml-1 d-1",
              med.low  = "0,25 mg prey added ml-1 d-1",
              med.high = "0.5 mg prey added ml-1 d-1",
              high     = "1.0 mg prey added ml-1 d-1",
              air.temp = "air temperature measured just
              above all plants (1 thermocouple)",
              water.temp = "water temperature measured within each pitcher",
              par       = "photosynthetic active radiation (PAR)
              measured just above all plants (1 sensor)"
            )

            value.i <- c(
              control  = "% dissolved oxygen",
              low      = "% dissolved oxygen",
              med.low  = "% dissolved oxygen",
              med.high = "% dissolved oxygen",
              high     = "% dissolved oxygen",
              air.temp = "degrees C",
              water.temp = "degrees C",
              par      = "micromoles m-1 s-1"
            )

            ## Write these into the data.frame format
            factors <- rbind(
              data.frame(
                attributeName = "i.flag",
                code = names(i.flag),
                definition = unname(i.flag)
              ),
              data.frame(
                attributeName = "variable",
                code = names(variable),
                definition = unname(variable)
              ),
              data.frame(
                attributeName = "value.i",
                code = names(value.i),
                definition = unname(value.i)
              )
            )
            attributeList <-
              set_attributes(
                attributes,
                factors,
                col_classes = c(
                  "character",
                  "Date",
                  "Date",
                  "Date",
                  "factor",
                  "factor",
                  "factor",
                  "numeric"
                )
              )
            expect_is(attributeList, "list")
            })

test_that("The set_attributes function stops if
          missing required fields in attributes",
          {
            # attributeName
            attributes <- data.frame(
              attributeName = NA,
              attributeDefinition = "date",
              measurementScale = "dateTime",
              domain = "dateTimeDomain",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))

            attributes <- data.frame(
              attributeDefinition = "date",
              measurementScale = "dateTime",
              domain = "dateTimeDomain",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))

            # attributeDefinition
            attributes <- data.frame(
              attributeName = "date",
              measurementScale = "dateTime",
              domain = "dateTimeDomain",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))


            attributes <- data.frame(
              attributeName = "date",
              attributeDefinition = NA,
              measurementScale = "dateTime",
              domain = "dateTimeDomain",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))

            # measurementScale
            attributes <- data.frame(
              attributeName = "date",
              attributeDefinition = "date",
              domain = "dateTimeDomain",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))

            attributes <- data.frame(
              attributeName = "date",
              attributeDefinition = "date",
              measurementScale = NA,
              domain = "dateTimeDomain",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))

            attributes <- data.frame(
              attributeName = "date",
              attributeDefinition = "date",
              measurementScale = "datetime",
              domain = "dateTimeDomain",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))

            # domain
            attributes <- data.frame(
              attributeName = "date",
              attributeDefinition = "date",
              measurementScale = "dateTime",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))

            attributes <- data.frame(
              attributeName = "date",
              attributeDefinition = "date",
              measurementScale = "dateTime",
              domain = NA,
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))

            attributes <- data.frame(
              attributeName = "date",
              attributeDefinition = "date",
              measurementScale = "dateTime",
              domain = "numberdomain",
              formatString = "YYMMDD"
            )

            expect_error(set_attributes(attributes))
          })

test_that(
  "The set_attributes function stops if non permitted
  values in col_classes or wrong length of col_classes",
  {
    attributes <-
      data.frame(
        attributeName = c(
          "run.num",
          "year",
          "day",
          "hour.min",
          "i.flag",
          "variable",
          "value.i",
          "length"
        ),
        formatString = c(NA,
                         "YYYY",
                         "DDD",
                         "hhmm",
                         NA,
                         NA,
                         NA,
                         NA),
        definition = c("which run number",
                       NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       NA),
        unit = c(NA,
                 NA,
                 NA,
                 NA,
                 NA,
                 NA,
                 NA,
                 "meter"),
        attributeDefinition = c(
          "which run number (=block). Range: 1 - 6. (integer)",
          "year, 2012",
          "Julian day. Range: 170 - 209.",
          "hour and minute of observation. Range 1 - 2400 (integer)",
          "is variable Real, Interpolated or Bad (character/factor)",
          "what variable being measured in what treatment (character/factor).",
          "value of measured variable for run.num on year/day/hour.min.",
          "length of the species in meters (dummy example of numeric data)"
        ),
        numberType = c(NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       "real"),
        stringsAsFactors = FALSE
      )
    i.flag <- c(R = "real",
                I = "interpolated",
                B = "bad")
    variable <- c(
      control  = "no prey added",
      low      = "0.125 mg prey added ml-1 d-1",
      med.low  = "0,25 mg prey added ml-1 d-1",
      med.high = "0.5 mg prey added ml-1 d-1",
      high     = "1.0 mg prey added ml-1 d-1",
      air.temp = "air temperature measured just above all
      plants (1 thermocouple)",
      water.temp = "water temperature measured within each pitcher",
      par       = "photosynthetic active radiation (PAR)
      measured just above all plants (1 sensor)"
    )

    value.i <- c(
      control  = "% dissolved oxygen",
      low      = "% dissolved oxygen",
      med.low  = "% dissolved oxygen",
      med.high = "% dissolved oxygen",
      high     = "% dissolved oxygen",
      air.temp = "degrees C",
      water.temp = "degrees C",
      par      = "micromoles m-1 s-1"
    )

    ## Write these into the data.frame format
    factors <- rbind(
      data.frame(
        attributeName = "i.flag",
        code = names(i.flag),
        definition = unname(i.flag)
      ),
      data.frame(
        attributeName = "variable",
        code = names(variable),
        definition = unname(variable)
      ),
      data.frame(
        attributeName = "value.i",
        code = names(value.i),
        definition = unname(value.i)
      )
    )
    expect_error(set_attributes(
      attributes,
      factors,
      col_classes = c(
        "character",
        "Date",
        "Date",
        "Date",
        "factor",
        "factor",
        "numeric"
      )
    ))
    expect_error(set_attributes(
      attributes,
      factors,
      col_classes = c(
        "character",
        "Date",
        "Date",
        "Date",
        "factor",
        "factor",
        "lalala",
        "numeric"
      )
    ))

    attributes <-
      data.frame(
        attributeName = c("run.num", "year", "day"),
        formatString = c(NA, "YYYY", "DDD"),
        definition = c("which run number", NA, NA),
        unit = c(NA, NA, NA),
        attributeDefinition = c(
          "which run number (=block). Range: 1 - 6. (integer)",
          "year, 2012",
          "Julian day. Range: 170 - 209."
        ),
        numberType = c(NA, NA, NA),
        domain = c("numericDomain", "numericDomain", "numericDomain"),
        measurementScale = c("ratio", "nominal", "interval"),
        stringsAsFactors = FALSE
      )
    expect_error(set_attributes(
      attributes,
      col_classes = list(run_numero = "character", year = "Date")
    ))
    expect_error(set_attributes(
      attributes,
      col_classes = list(
        run.num = "Date",
        year = "Date",
        day = "Date"
      )
    ))
    expect_error(
      set_attributes(attributes,
                     col_classes = list("Date", "Date", "Date")))

    attributes <-
      data.frame(
        attributeName = c("run.num", "year", "day"),
        formatString = c(NA, "YYYY", "DDD"),
        definition = c("which run number", NA, NA),
        unit = c(NA, NA, NA),
        attributeDefinition = c(
          "which run number (=block). Range: 1 - 6. (integer)",
          "year, 2012",
          "Julian day. Range: 170 - 209."
        ),
        numberType = c(NA, NA, NA),
        measurementScale = c("ratio", "nominal", "interval"),
        stringsAsFactors = FALSE
      )
    expect_error(set_attributes(
      attributes,
      col_classes = list(
        run.num = "numeric",
        year = "Date",
        day = "Date"
      )
    ))

    expect_error(
      set_attributes(attributes,
                     col_classes = list("Date", "Date", "Date")))

    attributes <-
      data.frame(
        attributeName = c("run.num", "year", "day"),
        formatString = c(NA, "YYYY", "DDD"),
        definition = c("which run number", NA, NA),
        unit = c(NA, NA, NA),
        attributeDefinition = c(
          "which run number (=block). Range: 1 - 6. (integer)",
          "year, 2012",
          "Julian day. Range: 170 - 209."
        ),
        numberType = c(NA, NA, NA),
        storageType = c("float", "float", "float"),
        stringsAsFactors = FALSE
      )
    expect_error(set_attributes(
      attributes,
      col_classes = list(
        run.num = "numeric",
        year = "Date",
        day = "Date"
      )
    ))

    expect_error(
      set_attributes(attributes,
                     col_classes = list("Date", "Date", "Date")))


  }
)

test_that("The set_attributes function
          returns useful warnings", {
            attributes <- data.frame(
              attributeName = "date",
              attributeDefinition = "date",
              measurementScale = "dateTime",
              domain = "dateTimeDomain"
            )

            expect_warning(set_attributes(attributes),
                           "The required formatString")
            })


test_that(
  "The set_attributes function stops if missing required fields in factors",
          {
            # attributesList
            attributes <-
              data.frame(
                attributeName = c("animal",
                                  "age",
                                  "size"),
                attributeDefinition = c("animal species",
                                        "life stage",
                                        "body length"),
                formatString = c(NA,
                                 NA,
                                 NA),
                definition = c("animal species",
                               "life stage",
                               "body length"),
                unit = c(NA,
                         NA,
                         "meter"),
                numberType = c(NA,
                               NA,
                               "real"),
                stringsAsFactors = FALSE
              )

            # two of the attributes are factors
            animal.codes <- c(A = "monstercat",
                              B = "monsterdog")
            age.codes <- c(A = "juvenile",
                           B = "adult")
            factors <- rbind(
              data.frame(
                code = names(animal.codes),
                definition = unname(animal.codes)
              ),
              data.frame(
                code = names(age.codes),
                definition = unname(age.codes)
              )
            )

            expect_error(
              set_attributes(
                attributes,
                factors,
                col_classes = c("factor", "factor", "numeric")
              ),
              "The factors data.frame should have"
            )

          })
test_that(
  "The set_attributes function stops if duplicate codes in factors",
          {
            # attributesList
            attributes <-
              data.frame(
                attributeName = c("animal",
                                  "age",
                                  "size"),
                attributeDefinition = c("animal species",
                                        "life stage",
                                        "body length"),
                formatString = c(NA,
                                 NA,
                                 NA),
                definition = c("animal species",
                               "life stage",
                               "body length"),
                unit = c(NA,
                         NA,
                         "meter"),
                numberType = c(NA,
                               NA,
                               "real"),
                stringsAsFactors = FALSE
              )

            # two of the attributes are factors
            animal.codes <- c(A = "monstercat",
                              B = "monsterdog")
            age.codes <- c(A = "juvenile",
                           B = "adult")
            factors <- rbind(
              data.frame(
                attributeName = "animal",
                code = names(animal.codes),
                definition = unname(animal.codes)
              ),
              data.frame(
                attributeName = "age",
                code = c("A", "A"),
                definition = unname(age.codes)
              )
            )

            expect_error(set_attributes(
              attributes,
              factors,
              col_classes = c("factor", "factor", "numeric")
            ),
            regex = "There are attributeName")
          })
