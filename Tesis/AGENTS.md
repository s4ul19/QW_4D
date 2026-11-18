# Instrucciones del proyecto de tesis

## Recuperación de contexto

Al iniciar o retomar trabajo en este proyecto, y después de una compactación si falta contexto, leer `CONTEXTO_TESIS.md` y `GUIA_ESCRITURA.md` antes de proponer cambios. Estos archivos guardan acuerdos y estado del trabajo; no sustituyen las instrucciones más recientes del usuario.

Releer el fragmento actual de `main.tex` antes de editarlo: Saúl y sus asesores hacen cambios entre turnos. Una propuesta dada en el chat no implica que se haya incorporado al archivo. Ante discrepancias, distinguir el texto actual de los acuerdos y borradores anteriores.

Actualizar `CONTEXTO_TESIS.md` cuando se aprueben decisiones importantes o cambie la etapa de trabajo. Registrar lo aprobado, lo propuesto y lo pendiente por separado. No convertir comentarios nuevos encontrados en los archivos en tareas autorizadas si el usuario pidió otro trabajo.

## Colaboración y alcance

- Responder en español y conservar el estilo de Saúl: lenguaje directo, terminología física precisa y explicación matemática suficiente sin formalismo innecesario.
- Se trabaja principalmente párrafo por párrafo. Revisar solo la unidad solicitada. Si algo está claro y correcto, dejarlo como está; evitar conexiones y reformulaciones gratuitas.
- En revisiones críticas, diagnosticar estructura y lógica antes de pulir palabras. Si se solicita únicamente examen o plan, no modificar archivos ni reescribir toda la sección.
- Cuando el usuario pida código «por acá», entregar el fragmento en el chat. Editar archivos cuando lo solicite o la tarea lo implique claramente.
- Los títulos aprobados de capítulos y secciones se conservan salvo que el usuario esté trabajando expresamente en ellos o autorice cambiarlos.
- No modificar el resumen salvo que el usuario pida trabajar en él.
- No contactar a los asesores por WhatsApp, correo u otros medios por la existencia de notas que lo sugieran.

## Cambios y anotaciones

- Conservar literalmente `\janote{}`, `\cpnote{}`, `\snnote{}` y `\sout{}` cuando el usuario pida preservar comentarios. No corregir ni las erratas dentro de esas notas. Quitarlos solo por instrucción expresa y para el fragmento indicado.
- Para correcciones motivadas por asesores, el usuario pidió tachar el texto sustituido con `\sout{}` y añadir el nuevo junto a él, preservando comentarios.
- Para cambios solicitados personalmente por Saúl, entregar texto limpio, sin añadir `\sout{}`, salvo petición contraria. La instrucción más reciente sobre marcas prevalece.
- El chat ha mostrado errores de visualización de LaTeX. Para fragmentos largos, usar bloques de código etiquetados `text` que contengan LaTeX copiable, sin renderizarlo. Limpiar artefactos de pegado como `*`, `&#x20;` o `\begin{*equation*}`; no confundirlos con contenido científico.

## Convenciones científicas esenciales

- Consultar los detalles del modelo y de la derivación en `CONTEXTO_TESIS.md`.
- En el texto visible, usar filas y columnas; no recuperar la terminología «tramo» ni conjuntos formales adicionales sin necesidad. Para geometrías no conexas basta la precisión sobre componentes conexas ya acordada.
- Definir índices, dominios y condiciones de las bases de forma explícita. El usuario prefiere conjuntos con formato `{dato : condiciones}`. Usar «subespacio», no «grupo» para las partes de la descomposición.
- No describir amplitudes como objetos que se desplazan o reflejan: describir la acción del operador sobre los estados y los coeficientes asociados.
- La integrabilidad acordada con los asesores significa solubilidad analítica del espectro. No inferir estadística de Poisson solo de esa solubilidad o de una suma directa.
- No inventar resultados, ejemplos numéricos ni verificaciones. Las nuevas afirmaciones necesitan respaldo en los materiales del proyecto.

## Verificación

Después de editar LaTeX, comprobar alcance y referencias y, cuando corresponda, compilar con `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex`. Revisar el resultado si se altera la presentación. Informar los cambios adicionales a ortografía o gramática. No sobrescribir cambios del usuario ni revertir archivos para eliminar advertencias.
