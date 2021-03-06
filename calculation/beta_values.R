

beta_values <- read.table("calculation/2020-01-07Beta100.csv",  sep = ",", header = TRUE)
cpt_wru <- read_excel("calculation/2019-11-19 NSQIP CPT Rates.xlsx")
cpt_wru <- cpt_wru[cpt_wru$CPT %in% c(55866,38571,50543,52234,52235,52240), ]
spec_list = as.character(beta_values[beta_values$Variable == "SURGSPEC", ]$ClassVal0)
over_65 = read_csv("calculation/over_65_risk.csv")
under_65 = read_csv("calculation/under_65_risk.csv")


format_inputs = function(cpt, age, asa_class, emergency, fn_status, in_out, spec, risk){
  data_vals = cpt_wru %>% filter(CPT == cpt)
  wRVU = data_vals$AMAWorkRVU[[1]]
  risk_val = data_vals[paste(risk, "Rate", sep = "")][[1]][1]
  asa_l =  c()
  for (x in seq(1:4)){
    if (asa_class == (x+1)){
      asa_l = c(asa_l,1)
    }else{
      asa_l = c(asa_l,0)
    }
  }
  fn_l =  c()
  for (x in seq(1:2)){
    if (fn_status == (x+1)){
      fn_l = c(fn_l,1)
    }else{
      fn_l = c(fn_l,0)
    }
  }
  spec_l = c()
  for (x in spec_list){
    if (spec == x){
      spec_l = c(spec_l,1)
    }else{
      spec_l = c(spec_l,0)
    }
  }
  return (c(risk, age, wRVU, asa_l, risk_val, emergency,fn_l,in_out, spec_l ))
}

calculate_risk = function(inputs){
  temp_beta = beta_values[inputs[1]][[1]]
  value = temp_beta[1]
  i = 2
  for (x in inputs[seq(2, length(inputs))]){
    value = value + (temp_beta[i]*as.numeric(x))
    i = i+1
  }
  return (plogis(value))
}

compare_chance = function(risk, value, cpt, age){
  data_vals = cpt_wru %>% filter(CPT == cpt)
  risk_val = data_vals[paste(risk, "Rate", sep = "")][[1]][1]
  subset = NULL
  if(age > 65){
    subset = over_65[over_65$cpts == cpt & over_65$risk == risk,]
    subset$sds = subset$sds2
    subset$means = subset$means2
    
  }else{
    subset = under_65[under_65$cpts == cpt & under_65$risk == risk,]
  }

  #if (as.numeric(value) > (2*as.numeric(subset$sds[1]) + as.numeric(subset$means[1]))){
    return ("Above Average")
  #}else if (as.numeric(value) <(as.numeric(subset$means[1]) - 2*as.numeric(subset$sds[1]))){
    return ("Below Average")
  #}else{
    return ("Average")
  #}
}

calculate_risk(format_inputs(52235, 40, 3, 1, 3, 1, "Orthopedics", "UTI"))
risk = c("Respiratory", "Infection", "UTI", "VTE", "Cardiac", "Renal", "Stroke", "Death30Day", "Unplannedreadmission")
discharge = c("Death30Day", "NotHome")
risk_name_dictionary = hash()
risk_name_dictionary[["Respiratory"]] = "Respiratory Complications"
risk_name_dictionary[["Infection"]] = "Infection"
risk_name_dictionary[["UTI"]] = "Urinary Tract Infection"
risk_name_dictionary[["VTE"]] = "Venous thromboembolism"
risk_name_dictionary[["Cardiac"]] = "Cardiac Complications"
risk_name_dictionary[["Renal"]] = "Renal Complications"
risk_name_dictionary[["Stroke"]] = "Stroke Complications"
risk_name_dictionary[["Death30Day"]] = "Mortality"
risk_name_dictionary[["Unplannedreadmission"]] = "Unplanned Readmission"


make_risk_df = function(cpt, age, asa_class, emergency, fn_status, in_out, spec){
  events <- c()
  i = 0
  for (x in risk){
    i = i+1
    value = calculate_risk(format_inputs(cpt, age, asa_class, emergency, fn_status, in_out, spec, x))
    events[[i]] = c(risk_name_dictionary[[x]], compare_chance(x, value, cpt, age), value)
  }
  events_df = as.data.frame(do.call(rbind, events))
  events_df[["V3"]] = as.numeric(as.character(events_df[["V3"]]))
  events_df <- events_df[order(-events_df$V3),]
  return (events_df)
}

make_discharge_list = function(cpt, age, asa_class, emergency, fn_status, in_out, spec){
  events <- c()
  #tot = 0
  #death = calculate_risk(format_inputs(cpt, age, asa_class, emergency, fn_status, in_out, spec, 'Death30Day'))
  not_home = calculate_risk(format_inputs(cpt, age, asa_class, emergency, fn_status, in_out, spec, 'NotHome'))
  #unplanned_readmission = calculate_risk(format_inputs(cpt, age, asa_class, emergency, fn_status, in_out, spec, 'Unplannedreadmission'))
  #Vector of Discharges (home, rehab, and death)
  #events = c((1-not_home-unplanned_readmission), (not_home + unplanned_readmission -death) , death)
  events = c((1-not_home), not_home)
  return (events)
}