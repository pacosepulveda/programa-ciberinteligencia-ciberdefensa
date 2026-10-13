# Micro-lab 4.C — Secret Exposure Drill

**Duración:** 20–30 minutos  
**Máquina:** `KALI01`

## Objetivo

Analizar un repositorio de laboratorio que contiene artefactos sintéticos de configuración y comprender que retirar una credencial expuesta del árbol actual no completa la respuesta: también deben evaluarse el historial, la rotación o revocación, la posible utilización y los controles preventivos.

Todos los valores del escenario son **ficticios, generados localmente y exclusivos del laboratorio**. No autentican contra ningún servicio real.

## 1. Prepara el escenario

Desde esta carpeta:

```bash
chmod +x create_telvora_dev_repo.sh
./create_telvora_dev_repo.sh ~/m04/telvora-dev-repo
cd ~/m04/telvora-dev-repo
```

No publiques el repositorio generado en ningún servicio remoto.

## 2. Revisión

Revisa tanto el árbol actual como el historial Git utilizando las herramientas de búsqueda y revisión disponibles en `KALI01`. Si `gitleaks` está instalado, puedes utilizarlo como comprobación adicional.

Completa:

| Artefacto | Current tree? | Git history? | Exposure | Likely impact |
|---|---|---|---|---|
| | | | | |

## 3. Respuesta

Para cada hallazgo responde:

1. ¿basta con eliminarlo de la versión actual?
2. ¿debe revocarse o rotarse?
3. ¿qué consumidores podrían verse afectados por el cambio?
4. ¿qué registros revisarías para buscar un posible uso indebido?
5. ¿qué ventana temporal revisarías?
6. ¿qué control preventivo evitaría una exposición equivalente?

## 4. Pregunta crítica

¿Por qué almacenar una credencial en un gestor de secretos puede seguir siendo insuficiente si el workload necesita otra credencial estática y de larga duración para autenticarse contra ese gestor?

## 5. Entregable

`secret-exposure-review.md` con:

- inventario de exposiciones;
- clasificación por impacto;
- acciones de rotación/revocación;
- investigación propuesta;
- controles preventivos;
- riesgo residual.
