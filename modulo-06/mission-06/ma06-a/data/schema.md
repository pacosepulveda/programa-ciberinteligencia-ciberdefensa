# Modelo de observaciones MA06.A

Los dos datasets están marcados synthetic=true y usan .example, además de IP reservadas para documentación. No deben resolverse contra Internet.

Cada captura contiene:
- case, scope, synthetic y captured_at.
- dns: diccionario hostname → record type → observación.
- Cada observación DNS: status (ok, nxdomain, timeout, unavailable), values (lista de strings) y observed_at.
- ct: lista de registros con id, dns_names, not_before y observed_at.
- provenance: fuente y limitaciones.

El comparador produce un objeto JSON:
~~~json
{
  "schema_version": "1.0",
  "events": [
    {
      "type": "A_CHANGED",
      "subject": "nombre-de-ejemplo",
      "severity": "alert",
      "details": "explicación sin atribución"
    }
  ]
}
~~~

Tipos orientativos: MX_CHANGED, A_CHANGED, NEW_DNS_HOST, CT_NEW_NAME_UNRESOLVED y SOURCE_UNAVAILABLE. Un conjunto ordenado de respuestas DNS no implica prioridad; en MX conserva preferencia y valor. Para NS/CNAME compara conjuntos sin importar el orden. No deduzcas cierre de servicios a partir de fallos de observación.
