# MA06.A — Pistas técnicas

1. Para comparar RRsets DNS, convierte values en sets; evita comparar listas según posición.
2. Antes de usar los valores, comprueba el campo status. timeout/unavailable significan que **no existe una observación válida del estado actual**.
3. Haz la unión de hostnames de los dos snapshots. Un hostname presente solo en el segundo, con registro A/AAAA válido, puede ser un nuevo nombre observado.
4. Para CT, construye el conjunto de nombres de dns_names de cada snapshot; comprueba por separado la resolución DNS del nombre nuevo.
5. Representa las aristas del grafo como relaciones observadas, no como atribución de propiedad.
6. Si el colector recibe HTTP 200 con JSON DNS Status distinto de 0, no lo clasifiques automáticamente como éxito.
7. El validador comprueba hechos de prueba conocidos del CASE, no los datos cambiantes del LIVE.
