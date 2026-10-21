# Cambios aplicados a P04.1

- Eliminada la referencia a duración del laboratorio.
- Añadidos comandos guiados para creación de CA, CSR y certificados.
- Añadidas pruebas explícitas con `openssl s_server` y `openssl s_client`.
- Añadidos casos reproducibles de CA no confiable y hostname mismatch.
- Añadida generación guiada de certificados `mqtt`, `sensor01` y `analyst01`.
- Añadida verificación de correspondencia entre certificado y clave privada.
- Añadida solución detallada desde máquinas apagadas.
- Añadido `.gitignore` para evitar subir accidentalmente claves y artefactos generados.
