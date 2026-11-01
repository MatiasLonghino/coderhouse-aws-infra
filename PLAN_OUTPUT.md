# Terraform Plan - Entorno DEV

## Evidencia histórica del primer entregable

Esta sección conserva el plan inicial de Network e Identity. Sus cifras y estado corresponden a esa ejecución histórica, no al cierre de la Fase 1.

### Configuración

- Entorno: dev.
- Región: us-east-2 (Ohio).
- Infraestructura: Network + Identity.
- Backend: Amazon S3 + DynamoDB.

### Comando ejecutado

```bash
terraform plan
```

### Resultado

```text
Plan: 11 to add, 0 to change, 0 to destroy.
```

### Recursos planificados

| Recurso | Cantidad |
|---|---:|
| VPC | 1 |
| Subredes privadas | 2 |
| Tabla de rutas | 1 |
| Asociaciones de rutas | 2 |
| S3 Gateway Endpoint | 1 |
| Roles IAM | 2 |
| Políticas IAM | 2 |
| **Total** | **11** |

### Estado en el momento de esta evidencia

Plan generado correctamente. El registro original indicaba que todavía no se había ejecutado `terraform apply`; el README del primer entregable registró posteriormente su despliegue exitoso.

### Evidencia de ejecución

![Resultado histórico de Terraform Plan](evidences/terraform-plan.png)

## Preparación del segundo entregable: cierre de la Fase 1

### Implementación revisada en el repositorio

El módulo `storage` está integrado en `enviroments/dev`. Define:

- `aws_s3_bucket.data`: bucket del Data Lake.
- `aws_s3_bucket_server_side_encryption_configuration.data`: SSE-S3 con AES256.
- `aws_s3_bucket_public_access_block.data`: bloqueo público completo.
- `aws_s3_bucket_ownership_controls.data`: propiedad `BucketOwnerEnforced` y ACL deshabilitadas.

DEV obtiene dinámicamente el identificador de cuenta para el nombre predeterminado y permite un nombre alternativo. Identity recibe el nombre desde Storage y conserva su restricción a `raw/`. No se modificaron los módulos Network e Identity ni `enviroments/dev/backend.tf` durante esta integración.

### Resultados confirmados por el usuario

Estas confirmaciones fueron proporcionadas por el usuario al solicitar el Bloque 7. No son resultados de comandos ejecutados durante la documentación:

| Verificación | Resultado comunicado |
|---|---|
| Despliegue con `terraform apply` | Finalizó exitosamente; bucket `coderhouse-data-925213028629` creado |
| Región | Bucket verificado en `us-east-2` |
| Cifrado | SSE-S3 habilitado |
| Acceso público | Bloqueado |
| Propiedad de objetos y tags | Configuración correcta |
| Backend | `coderhouse-tfstate-925213028629` permanece disponible para el estado remoto |
| Plan final | `No changes` |
| Outputs | `terraform output` muestra correctamente las salidas correspondientes |

Se resolvieron errores de permisos IAM para operaciones S3. Tras comprobar que el bucket existía en AWS, se retiró su marca `tainted`. El usuario confirmó que ambos problemas quedaron solucionados. No se incluyen políticas sensibles ni instrucciones para alterar el estado.

No se dispone del resumen textual del último Apply: no se atribuye una cantidad exacta de recursos agregados, modificados o destruidos. Los cuatro recursos enumerados arriba describen el código de Storage, no el conteo del Apply final.

### Evidencias pendientes de adjuntar

- Salida textual o captura revisada del último `terraform apply`, incluido su resumen final.
- Salida textual o captura revisada del plan final con `No changes`.
- Salida revisada de `terraform output` con las salidas del Data Lake.
- Capturas de las verificaciones de S3: región, cifrado, bloqueo público, propiedad y etiquetas.

La captura histórica existente no sustituye estas evidencias. Revisar cualquier adjunto antes de publicarlo para evitar incluir secretos o detalles de autenticación.

### Alcance del cierre

La Fase 1 deja la infraestructura base preparada para la futura capa Bronze bajo `bronze/ingesta/year=YYYY/month=MM/day=DD/`. No se crearon carpetas ni datos mediante Storage. Kinesis, Firehose, productores Python y alarmas CloudWatch siguen pendientes.

Este bloque modifica documentación y exclusiones de Git; no ejecuta Terraform, AWS CLI ni operaciones sobre AWS.
