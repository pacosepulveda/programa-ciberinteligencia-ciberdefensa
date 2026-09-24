# Contexto Telvora — MA01 Shadow Exposure

Telvora Communications utiliza un segmento aislado de laboratorio para validar servicios antes de incorporarlos a entornos más amplios.

El inventario se genera a partir de varias fuentes y puede presentar retrasos o campos incompletos. El objetivo de esta misión no es demostrar un ataque, sino contrastar documentación con evidencia técnica.

## Entorno conocido

- Red autorizada: `10.20.0.0/24`
- Estación de análisis: `KALI01`
- Servidor Linux: `LINUX01`
- Servicio de directorio: `AD01`
- Dominio: `TELVORA.LAB`

## Principio de análisis

Una observación técnica debe clasificarse antes de convertirla en conclusión:

```text
dato → evidencia → interpretación → hipótesis → decisión
```

Un servicio expuesto no implica automáticamente una vulnerabilidad ni un compromiso.
