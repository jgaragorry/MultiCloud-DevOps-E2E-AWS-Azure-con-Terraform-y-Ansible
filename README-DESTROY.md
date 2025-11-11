# 🧹 Guía de Destrucción Completa (FinOps)

Para asegurar que no se incurra en ningún costo residual en AWS o Azure, es **crítico** seguir el orden de destrucción correcto.

El proyecto está diseñado con una **Separación de Ciclo de Vida (Mejor Práctica SRE)**:
1.  **La Infraestructura:** Las VMs, Redes, IPs, etc. Son *volátiles* (se crean y destruyen a menudo).
2.  **El Backend:** El Storage Account en Azure que contiene el archivo de estado (`.tfstate`). Es *persistente* (contiene el historial).

**NUNCA** destruyas el Backend (Paso 2) antes de destruir la Infraestructura (Paso 1). Si lo haces, Terraform perderá el "mapa" de tus recursos y no podrá eliminarlos, resultando en "recursos huérfanos" que siguen generando costos.

---

### Paso 1 (Crítico): Destruir la Infraestructura (VMs, Redes, IPs)

Este comando utiliza el `backend` (Paso 2) para leer el archivo de estado (`.tfstate`) y destruir metódicamente todos los 21 recursos que gestiona (las 3 VMs, redes, firewalls, etc.) en ambas nubes.

1.  Asegúrate de estar en el directorio raíz del proyecto.
2.  Ejecuta el script de destrucción de la infraestructura:
    ```bash
    ./scripts/infra_deployment/destroy_infra.sh
    ```
3.  Terraform calculará un plan de `Plan: 0 to add, 0 to change, 21 to destroy.`
4.  Confirma la destrucción escribiendo `destruir` cuando se te solicite.
5.  Espera a que el proceso termine.
    * **Resultado Esperado:** `Destroy complete! Resources: 21 destroyed.`

---

### Paso 2 (Limpieza Total): Destruir el Backend (El Estado)

Ahora que la infraestructura ha sido eliminada, el único recurso que queda es el Resource Group en Azure que aloja nuestro archivo de estado.

**Ejecuta este paso solo si has terminado el workshop y no planeas redesplegar la infraestructura inmediatamente.**

1.  Exporta la variable `BASE_NAME` que usaste al crear el backend. (Si no la recuerdas, puedes encontrarla en tu archivo `terraform_infra/main.tf` o en el portal de Azure).
    ```bash
    # Ejemplo (¡Usa el tuyo!)
    export BASE_NAME="wstfstate-obs-630"
    ```
2.  Ejecuta el script de destrucción del backend:
    ```bash
    ./scripts/backend_bootstrap/azure/destroy_backend_azure.sh
    ```
3.  Confirma la destrucción escribiendo `destruir`.
    * **Resultado Esperado:** `--- Backend Azure Destruido ---`

Con estos dos pasos completados, tus cuentas de AWS y Azure están **100% limpias** y no se generarán más cargos.
