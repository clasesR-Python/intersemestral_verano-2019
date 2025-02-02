

# dplyr y tidyverse -------------------------------------------------------
#+ setup, message = FALSE, warning = FALSE, error = FALSE


# Paquetes ----------------------------------------------------------------

library(tidyverse)
library(foreign)


# Descargar datos ---------------------------------------------------------

datos <- read.spss("Datos/GSS2018.sav", 
                   to.data.frame = TRUE,
                   max.value.labels = 5) 


# tbl_df ------------------------------------------------------------------

datos <- tbl_df(datos)


# Los cinco verbos del mal ------------------------------------------------



# 1. Select ---------------------------------------------------------------

mini_tbl <- select(datos, AGE, SEX, EVSTRAY)


# 2. Filter ---------------------------------------------------------------

filter(mini_tbl, EVSTRAY == "YES")


# 3. Arrange --------------------------------------------------------------

arrange(mini_tbl, AGE)


# 4. Mutate ---------------------------------------------------------------

mutate(mini_tbl, BORN = 2018 - AGE)


# 5. Summarise ------------------------------------------------------------

summarise(mini_tbl, media = mean(AGE, na.rm = TRUE))


# Operador %>% ------------------------------------------------------------

datos %>% 
  select(edad = AGE, sexo = SEX, infiel = EVSTRAY)


# select + filter ---------------------------------------------------------

datos %>% 
  select(edad = AGE, sexo = SEX, infiel = EVSTRAY) %>% 
  filter(infiel == "YES")


# select + filter + arrange -----------------------------------------------

datos %>% 
  select(edad = AGE, sexo = SEX, infiel = EVSTRAY) %>% 
  filter(infiel == "YES") %>% 
  arrange(edad)


# select + filter + arange + mutate ---------------------------------------

datos %>% 
  select(edad = AGE, sexo = SEX, infiel = EVSTRAY) %>% 
  filter(infiel == "YES") %>% 
  arrange(edad) %>% 
  mutate(
    nacio = 2018 - edad
  ) 


# select + filter + arange + mutate + summarise ---------------------------

datos %>% 
  select(edad = AGE, sexo = SEX, infiel = EVSTRAY) %>% 
  filter(infiel == "YES") %>% 
  arrange(edad) %>% 
  mutate(
    nacio = 2018 - edad
  ) %>% 
  summarise(
    mean = mean(edad),
    median = median(edad),
    sd = sd(edad),
    var = var(edad),
    min = min(edad),
    max = max(edad),
    n = n(),
    se = sd / sqrt(n),
    low = mean - 2 * se,
    upp = mean + 2 * se
  )


# Todos se pueden  usar con group_by --------------------------------------

datos %>% 
  select(edad = AGE, sexo = SEX, infiel = EVSTRAY) %>% 
  filter(!is.na(edad), !is.na(infiel)) %>% 
  group_by(infiel) %>% 
  summarise(
    mean = mean(edad),
    median = median(edad),
    sd = sd(edad),
    var = var(edad),
    min = min(edad),
    max = max(edad),
    n = n(),
    se = sd / sqrt(n),
    low = mean - 2 * se,
    upp = mean + 2 * se
  )


# select() ----------------------------------------------------------------

# Selecciona columnas por su nombre
datos %>% 
  select(AGE, SEX, EVSTRAY) 

# Selecciona todas las columnas entre ABANY y AGE
datos %>% 
  select(ABANY:AGE)

# Selecciona todas las columnas excepto las que están entre ABANY y AGE
datos %>% 
  select(-(ABANY:AGE))

# Todas las columnas que empiezan con "SEX"
datos %>% 
  select(starts_with("SEX"))

# Todas las columnas que terminan con "SEX"
datos %>% 
  select(ends_with("SEX"))

# Todas las columnas que contienen "SEX"
datos %>% 
  select(contains("SEX"))

# Selecciona y renombra
(mini_tbl <- datos %>% 
  select(edad = AGE, sexo = SEX, infiel = EVSTRAY, peso = WEIGHT, estatura = HEIGHT))


# mutate() ------------------------------------------------------------------


# Peso en kg
mini_tbl %>% 
  mutate(peso_kg = peso * 0.453592)

# Estatura en m
mini_tbl %>% 
  mutate(peso_kg = peso * 0.453592,
         estatura_m = estatura * 0.0254)

# IMC
mini_tbl %>% 
  mutate(peso_kg = peso * 0.453592,
         estatura_m = estatura * 0.0254,
         imc = peso_kg / estatura_m^2) 

# Dejamos peso_kg y estatura_m
(mini_tbl <- mini_tbl %>% 
  mutate(peso_kg = peso * 0.453592,
         estatura_m = estatura * 0.0254,
         imc = peso_kg / estatura_m ^ 2) %>% 
  select(-(peso:estatura)))


# filter() ----------------------------------------------------------------


# == 
mini_tbl %>% 
  filter(infiel == "YES")

# !=
mini_tbl %>% 
  filter(infiel != "YES")

# >
mini_tbl %>% 
  filter(imc > 30)

# <
mini_tbl %>% 
  filter(imc < 19)



# filter con operadores lógicos -------------------------------------------


# &
mini_tbl %>% 
  filter(sexo == "MALE" & infiel == "YES" )

# | 
mini_tbl %>% 
  filter(imc <= 19 | imc >= 30)

# %in%
mini_tbl %>% 
  filter(infiel %in% c("YES", "NO"))

# !
mini_tbl %>% 
  filter(!is.na(imc))


# arrange() ---------------------------------------------------------------

mini_tbl %>% 
  arrange(imc)


mini_tbl %>% 
  arrange(desc(imc))



# summarise() -------------------------------------------------------------

mini_tbl %>% 
  summarise(m_edad = mean(edad, na.rm = T),
            m_peso = mean(peso_kg, na.rm = T),
            m_esta = mean(estatura_m, na.rm = T),
            m_imc = mean(imc, na.rm = T))

mini_tbl %>% 
  group_by(sexo) %>% 
  summarise(m_edad = mean(edad, na.rm = T),
            m_peso = mean(peso_kg, na.rm = T),
            m_esta = mean(estatura_m, na.rm = T),
            m_imc = mean(imc, na.rm = T))



# Combinar múltiples operaciones ------------------------------------------


mini_tbl %>% 
  filter(infiel %in% c("YES", "NO")) %>% 
  mutate(infiel = fct_relevel(infiel, "NO")) %>% 
  ggplot(aes(x = estatura_m, y = peso_kg)) +
  geom_point(aes(size = edad, col = sexo), alpha = 0.2) +
  geom_smooth(method = "lm", alpha = 0.2) +
  geom_rug(aes(col = sexo), alpha = 0.5) +
  facet_wrap(~infiel) +
  labs(x = "Estatura (m)",
       y = "Peso (kg)",
       col = "Sexo",
       size = "Edad") +
  theme_bw()
  
