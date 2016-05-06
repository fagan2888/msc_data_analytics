# Research Project - Maria Athena B. Engesaeth
# 20_elasticity_selective_dde
#
# Prepare working environment----------------------------------------------------------

# load data amd utility models for parameters frames
source("./10_utility_analysis.R")  # also loads packages

# model2a <- mlogit(choice ~ price + promo_price, data=TM.coffee)
summary(model2a)

# model3b <- mlogit(choice ~ price + promo_price + loss + gain, data=TM.coffee)
summary(model3b)


# Compute Elasticity Selective Demand Excl LOSS -----------------------------------

# Then can use predict(model,data) but you need to be careful to change only the 
# price of one brand and notice that the model$probabilities already gives you
# the probabilities of each observation under the original data
excl_loss_coef <- model2a$coefficients
excl_loss_prob <- model2a$probabilities

# Carte Noire
carte_sel_el_exloss <- sd(excl_loss_coef[4] * excl_loss_prob[,1] * 
       (1 - excl_loss_prob[,1])) / mean(excl_loss_prob[,1]) / (
         1/mean(TM.coffee$price[TM.coffee$brand=="Carte Noire"]))

# Douwe Egbert
douwe_sel_el_exloss <- sd(excl_loss_coef[4] * excl_loss_prob[,1] * 
       (1 - excl_loss_prob[,1])) / mean(excl_loss_prob[,1]) / (
         1/mean(TM.coffee$price[TM.coffee$brand=="Douwe Egbert"]))

# Kenco 
kenco_sel_el_exloss <- sd(excl_loss_coef[4] * excl_loss_prob[,1] * 
       (1 - excl_loss_prob[,1])) / mean(excl_loss_prob[,1]) / (
         1/mean(TM.coffee$price[TM.coffee$brand=="Kenco"]))

# Nescafe
nescafe_sel_el_exloss <- sd(excl_loss_coef[4] * excl_loss_prob[,1] * 
       (1 - excl_loss_prob[,1])) / mean(excl_loss_prob[,1]) / (
         1/mean(TM.coffee$price[TM.coffee$brand=="Nescafe"]))


# Combine elasticities for each brand into single matrix
elasticities_exloss <- rbind(carte_sel_el_exloss,
                             douwe_sel_el_exloss,
                             kenco_sel_el_exloss,
                             nescafe_sel_el_exloss)

# Set rownames to be the same as column names
rownames(elasticities_exloss) <- c("carte", "douwe", "kenco", "nesca")


# Compute Elasticity Selective Demand Excl LOSS -----------------------------------

incl_loss_coef <- model3b$coefficients
incl_loss_prob <- model3b$probabilities
incl_loss_coef[4] <- -0.063566
# Carte Noire
carte_sel_in_exloss <- sd(incl_loss_coef[4] * incl_loss_prob[,1] * 
                              (1 - incl_loss_prob[,1])) / mean(incl_loss_prob[,1]) / (
                                1/mean(TM.coffee$price[TM.coffee$brand=="Carte Noire"]))

# Douwe Egbert
douwe_sel_in_exloss <- sd(incl_loss_coef[4] * incl_loss_prob[,1] * 
                              (1 - incl_loss_prob[,1])) / mean(incl_loss_prob[,1]) / (
                                1/mean(TM.coffee$price[TM.coffee$brand=="Douwe Egbert"]))

# Kenco 
kenco_sel_in_exloss <- sd(incl_loss_coef[4] * incl_loss_prob[,1] * 
                              (1 - incl_loss_prob[,1])) / mean(incl_loss_prob[,1]) / (
                                1/mean(TM.coffee$price[TM.coffee$brand=="Kenco"]))

# Nescafe
nescafe_sel_in_exloss <- sd(incl_loss_coef[4] * incl_loss_prob[,1] * 
                                (1 - incl_loss_prob[,1])) / mean(incl_loss_prob[,1]) / (
                                  1/mean(TM.coffee$price[TM.coffee$brand=="Nescafe"]))


# Combine elasticities for each brand into single matrix
elasticities_inloss <- rbind(carte_sel_in_exloss,
                             douwe_sel_in_exloss,
                             kenco_sel_in_exloss,
                             nescafe_sel_in_exloss)

# Set rownames to be the same as column names
rownames(elasticities_inloss) <- c("carte", "douwe", "kenco", "nesca")

# Print in console -----------------------------------------------------------------

elasticities_exloss
elasticities_inloss
