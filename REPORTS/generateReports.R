## Script to generate Reports

# Step 0: Load data
input_data <- read.delim("clinical/subjects_data.tsv", na.strings="N/A")

# Step 1: Diagnose_Report
diagnose_report(input_data, output_format = "html", output_file = "Diagnose_Report.html", output_dir = getwd(), browse = FALSE)
diagnose_report(input_data, output_format = "pdf", output_file = "Diagnose_Report.pdf", output_dir = getwd(), browse = FALSE)


# Step 2: EDA Report
eda_report(input_data, output_format = "html", output_file = "EDA_Report.html", output_dir = getwd(), browse = FALSE)
eda_report(input_data, output_format = "pdf", output_file = "EDA_Report.pdf", output_dir = getwd(), browse = FALSE)
