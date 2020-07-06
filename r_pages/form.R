output$pageStub <- renderUI(tagList(fluidRow(
  column(
    12,
    column(
      6,
      align = "left",
      
      numericInput(inputId = "age",
                   h4("Enter Patient Age"),
                   value = 18),
      selectInput(
        inputId = "asa_status",
        h4("American Society of Anesthesiology Class"),
        choices = list(
          "Please Select One" = 1,
          "ASA 1: Normal healthy patient." = 2,
          "ASA 2: Patient with mild systemic disease" = 3,
          "ASA 3: Patient with severe systemic disease" = 4,
          "ASA 4: Patient with severe systemic disease that is a constant threat to life" = 5,
          "ASA 6: Moribund patient who is not expected to survive without the operation" = 6
        ),
        selected = 1
      ),
      radioButtons(
        "func_status",
        h4("Functional Status"),
        choices = list(
          "Independant" = 1,
          "Partially Dependant" = 2,
          "Totally Dependant" = 3
        ),
        inline = FALSE
      ),
      
    ),
    column(
      6,
      align = "left",
      
      selectInput(
        inputId =  "surg_spec",
        h4("Surgeon Specialty"),
        choices = list(
          "Please Select One" = 1,
          "General" = 2,
          "Gynecologic" = 3,
          "Orthopedic" = 4,
          "Vascular Surgery" = 5
        ),
        selected = 1
      ),
      radioButtons(
        "em_case",
        h4("Emergency Case"),
        choices = list("Yes" = 1, "No" = 2),
        selected = 2,
        inline = TRUE
      ),
      
      
      radioButtons(
        "oper",
        h4("In-/Outpatient Operation"),
        choices = list("Inpatient" = 1, "Outpatient" = 2),
        inline = TRUE
      ),
    ),

    column(12, br(), br(), br(), br(), br(), br()),
    column(12, align = "center", div(id = "to_user", tags$a(
      h4("Next",  class = "btn btn-default btn-info action-button",
         style = "fontweight:600"),
      href = "?complications_single_col"
    ))),
  ),
  
)))