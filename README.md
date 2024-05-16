# Chicago-Crimes-2001-April-2024
En este proyecto se limpia, se normaliza y se analizan los datos de los crímenes de Chicago desde el 2001 hasta abril del 2024.

## Tabla de contenidos
- [Miembros](#miembros)
- [Introducción](#introduccion)
- [Carga inicial](#carga-inicial)
- [Limpieza de datos](#limpieza-de-datos)
- [Normalización de la base de datos](#normalizacion-de-la-base-de-datos)
- [Conclusión](#conclusion)

## Miembros
@mikehv03
@adolfoyunes1

## Introducción
En la actualidad, uno de los problemas que más ha llamado la atención es la inseguridad. Esto se debe a que cada día el acceso a armas es más fácil y, además, en muchos lugares la intervención de la policía es casi nula. Por lo tanto, muchas personas se empiecen a preocupar por cómo el gobierno va a erradicar esta situación, a tal nivel que la seguridad se vuelve uno de los temas políticos más importantes. Esto sucede en México, Venezuela, Estados Unidos, entre otros países.

  En los últimos años, la inseguridad en Estados Unidos ha aumentado. De acuerdo con Argemino Barro, el crimen en este país se disparó tras la pandemia. Y aunque esto ha sucedido a nivel federal, la gente de Chicago está particularmente preocupada. Según una encuesta realizada por The Sun en 2023, la mayoría de los ciudadanos dijeron que el problema más importante es el crimen, y el 63% de los encuestados comentaron que no se sentían seguros. Si bien el gobernador actual, J.B. Pritzker, dijo que los crímenes están disminuyendo (Chicago Sun-Times, 2023), las familias de Chicago no deberían sentirse inseguras y su seguridad no debería basarse solo en promesas de políticos.
  
  Lo anteriormente mencionado es una de las razones por las cuales es importante prestar mucha atención a la situación de los crímenes en una ciudad tan importante como Chicago. En el siguiente reporte se observará si es verdad que los crímenes están disminuyendo con el paso de los años. Además, se analizarán las zonas con mayor índice de criminalidad para que el gobierno de Chicago sepa en qué áreas se debe aumentar la seguridad.
  
  La base de datos utilizada para este análisis fue creada por el gobierno de Chicago y está disponible en su portal, es decir, en el Chicago Data Portal. En ella se encuentran todos los crímenes registrados por el Departamento de Policía de Chicago desde 2001 hasta abril de 2024, que fue cuando se realizó el análisis. Es importante mencionar que, aunque los datos son del Departamento de Policía de Chicago, gran parte de la información en esta base de datos es preliminar, y el gobierno de Chicago menciona que no se garantiza la exactitud de todos los datos. 

## Carga inicial
La base de datos viene del siguiente URL: https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2/about_data

  En la carga inicial de la base de datos, se encontraron aproximadamente ocho millones de tuplas (filas) y un total de veintidós atributos (columnas). Los atributos de Crimes 2001-Present son id, case_number, date, block, iucr, primary_type, description, location_description, arrest, domestic, beat, district, ward, community_area, fbi_code, x_coordinate, y_coordinate, year, updated_on, latitude, longitude, location. 
  
Para comprender mejor este proyecto se deben de explicar los siguientes atributos: 

    -	iucr (Illinois Uniform Crime Reporting Code): es el código que utiliza el gobierno de Illinois para clasificar a los crímenes.
    -	district: es el distrito de policía, es decir, la división administrativa de la policía en un área geográfica.
    -	ward: es el distrito, pero más en temas administrativos y electorales.
    -	community_area: es el municipio que se utiliza para la planificación y el análisis de servicios comunitarios.
    
  Otra observación realizada es que ciertos atributos deben descartarse debido a su irrelevancia para el objetivo del análisis o por ser atributos repetidos. Uno de estos atributos es year, ya que el año ya viene incluido en el atributo date. Además, debido a que el análisis de los crímenes en Chicago está más relacionado con la zona y no con la localización exacta donde ocurrió el crimen, se optó por eliminar los atributos latitude y longitude. También se decidió eliminar location, ya que solo repetía las coordenadas x e y. Por último, se eliminó beat porque era demasiado específico sobre qué área de policía manejó el delito.  Al quitar estos atributos logramos una base de datos más generalizada que nos pueda a llevar a conclusiones más realisatas y no tan específicas.

## Limpieza de datos
En primera instancia, se observó que el atributo location_description era muy específico. Por ejemplo, en lugar de decir aeropuerto, lo dividía en entrada al aeropuerto, estacionamiento del aeropuerto, entre otras categorías. Esto mismo sucedía con otras localizaciones, como universidad, parque, garaje, auto, etc. Si se quería hacer un análisis global de todos los crímenes en Chicago a lo largo de los años y de las zonas más afectadas, no era tan relevante tener descripciones tan detalladas. Por esa razón, se decidió simplificarlas.

  En segundo lugar, al momento de cargar la base de datos, se arrojó un error con el atributo date. Esto se debía a que PostgreSQL no detecta la fecha si incluye PM o AM. Por esta razón, en la tabla sin procesar se definió como un atributo de tipo texto y luego se modificó.
  
  Otra de las modificaciones que se realizaron a los datos principales fue eliminar todos los registros que no contuvieran ward, community_area o district. Se tomó esta decisión porque se quería evaluar el desempeño de esas áreas en función de quién las representa y determinar en qué lugares se debe aumentar la seguridad para mejorar la protección en la ciudad de Chicago. Se eligieron estos atributos por las siguientes razones:
  
    -	ward: permite identificar qué partido político está gobernando la zona.
    -	community_area: se quería identificar cuál es la zona más segura y la menos segura, y analizar los factores que contribuyen a esto.
    -	district: ayuda a identificar qué distrito policial necesita más recursos, ya que son los que tienen una mayor cantidad de casos.
    
  Para una mayor precisión en los códigos IUCR que utiliza la ciudad de Chicago, se incluyó una relación que no estaba en la base de datos original. Esta nueva base de datos contiene los códigos que utiliza el departamento de policía en 2021. Aunque no es la tabla más actualizada, se decidió incluirla porque menciona qué códigos seguían activos en 2021 y cuáles no, lo que permite un análisis más profundo de cómo han evolucionado los crímenes en los últimos años. Sin embargo, debido a que no son los códigos más actualizados, algunos IUCR no están completamente actualizados. Por ejemplo, en 2021 no había un código para personas que reciben imágenes sexuales sin consentimiento. Aun así, se observó que son muy pocos los códigos que no están actualizados, por lo que se buscó una correspondencia entre los códigos nuevos y los viejos y se procedió a cambiar los códigos. Algo similar ocurrió con los códigos del FBI.
  
  En la nueva tabla de IUCR, se observó que muchos códigos no tenían cuatro dígitos, mientras que en la relación de crimes sí se requerían cuatro dígitos. Por esta razón, se ajustaron los códigos para que tuvieran cuatro dígitos, agregando un 0 al principio si solo contaban con tres dígitos.
  
  Siguiendo con los IUCR, dentro de la base de datos original hay ciertos eventos que no son crímenes, pero en los que sí intervino la policía. Por ejemplo, la pérdida o recuperación de pasaportes. Como en este proyecto se buscan crímenes, se optó por eliminar todos los datos relacionados con el iucr_primary_type "Non-Criminal".
  
  Dentro de la relación de crimes, la cual se abordará más adelante, se observó que existían dos llaves candidatas: id y case_number. Al analizar bien la relación de crimes, se observó que case_number no era una súper llave porque contenía dos tuplas distintas con los mismos valores. Sin embargo, al buscar cuáles eran las tuplas distintas, se observó que contenían la misma información, variando solo el atributo date. Por esa razón, y para evitar datos duplicados, se optó por eliminar todas las tuplas similares que solo variaban en el atributo date. Al hacer esto, se obtuvo que case_id ya era una súper llave, lo cual se abordará más adelante.
 
## Normalización de la base de datos
A la relación inicial, es decir, cuando se descarga la base de datos y se eliminan los datos innecesarios, se la denominó E1. Por lo tanto, RI = {id, case_number, date, block, iucr, primary_type, description, location_description, arrest, domestic, district, ward, community_area, fbi_code, x_coordinate, y_coordinate, updated_on}. Al analizar esta relación, se encontró que estaba en 2NF (segunda forma normal) porque todos los atributos dependían completamente de case_number e id, que fueron las llaves candidatas encontradas. Es importante notar que, debido a la limpieza realizada, case_number e id eran las súper llaves; sin embargo, se prefirió utilizar solo case_number porque este atributo no se repetía y facilitaba la comprensión de las nuevas relaciones.

  Siguiendo con las formas normales, se encontraron las siguientes dependencias funcionales, eliminando id:
  
    {case_number} -> {date, block, iucr, primary_type, description, location_description, arrest, domestic, district, ward, community_area, fbi_code, x_coordinate, y_coordinate, updated_on}
		{iucr} -> {primary_type, description}
  
Dado que en ambos casos se encontraban iucr, primary_type y description, se analizó cómo transformarla a tercera forma normal. Para lograr esto, se utilizó el Teorema de Heath y la intuición, lo que resultó en las siguientes dos relaciones:
 
    R1 = {case_number, date, block, iucr, location_description, arrest, domestic, district, ward, community_area, fbi_code, x_coordinate, y_coordinate, updated_on}
	  R2 = {iucr, primary_type, description}
   
  Una vez se obtuvo la 3NF (tercera forma normal), se buscó si existían dependencias multivaluadas. Inicialmente, se pensó que dentro de la descripción de los IUCR había una dependencia multivaluada; sin embargo, esto no era cierto. Esto se debió a que el tipo de arma utilizada sí dependía del crimen cometido. Por esta razón, teóricamente, ambas relaciones, R1 y R2, ya se encontraban en 4NF (cuarta forma normal).
  
  El problema fue que entre la teoría y la práctica hay un “desacuerdo”. Aunque todas las relaciones estaban en cuarta forma normal, se encontraron ciertos datos que se repetían con frecuencia. Por ejemplo, de los aproximadamente ocho millones de datos, solo existían aproximadamente 370,000 bloques distintos. En location_description, existían solo 105 datos distintos. Y para finalizar, del primary_type de IUCR, se encontraron 33 tipos distintos. Por esta razón, se decidió crear una relación para cada uno de estos datos, para facilitar futuras modificaciones en el nombre de un bloque, delito o localización. Además, es importante mencionar que también se agregó otra relación que reflejaba el nombre de todos los códigos del FBI hasta 2021. Cabe recalcar que la relación de iucr también fue modificada para agregar el atributo de active. Por ello, las relaciones quedaron de la siguiente forma:
  
    crimes = {case_number, date, block_id, iucr_codes_id, fbi_code_id, location_id, arrest,     domestic, police_district, ward, community_area, x_coordinate, y_coordinate, updated_on}
	  block = {id, description}
	  location = {id, description}
	  fbi_code = {fbi_code, description}
	  iucr_codes = {iucr, primary_type_iucr_id, secondary_description, active}
	primary_type_iucr = {id, description}

## Conclusión
A lo largo de esta investigación, pudimos descubrir muchas estadísticas que ayudan a comprender el problema de seguridad que se vive actualmente. Para empezar, los crímenes venían disminuyendo año con año a lo largo de aproximadamente una década. Sin embargo, la preocupación de la gente ha aumentado en los últimos dos años, ya que la inseguridad ha repuntado. Las zonas más inseguras de la ciudad están muy relacionadas con las zonas marginadas, es decir, las áreas donde vive la gente con menos recursos son las que padecen mayor inseguridad; esta zona es el sur de Chicago.

Los crímenes más comunes son el robo y la agresión simple. Además, los lugares donde más se merma la seguridad son las calles y las residencias. Esto es un indicador de que no hay suficientes policías en las calles y que la división de distritos dentro de la ciudad probablemente no es la más eficiente. Se podría hacer una mejor distribución para obtener más control.

A lo largo de la investigación, destacamos que la gente tiene una lealtad sólida al partido demócrata. A pesar de la preocupación y el empeoramiento de los últimos años en temas de seguridad, la mayoría de la gente sigue confiando en su partido. Esto se debe, muy probablemente, a la mejora y estabilidad que ha experimentado su ciudad a lo largo de muchos años.

La inestabilidad entre los ciudadanos de Chicago está creciendo, y esto se debe a la impunidad que existe con los criminales. El 25% de los crímenes reportados no conlleva un arresto, lo que genera que los criminales vean dinero fácil sin correr ningún tipo de riesgo. Si esta tendencia continúa, se podría perder la paz de los ciudadanos de una ciudad tan importante como Chicago.
Por esta razón, se propone aumentar la cantidad de policías en las calles, especialmente en las zonas con mayor inseguridad. Además, se sugiere tratar de distribuir los ingresos de las personas de una manera diferente, en la que no haya tanta diferencia económica entre las zonas. Por último, se propone tener una mano más dura en los arrestos, ya que gran parte de las razones por las que algunas personas vuelven a cometer un delito es por la impunidad que creen tener.
