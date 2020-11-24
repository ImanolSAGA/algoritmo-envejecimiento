# algoritmo-envejecimiento

(Este es un proyecto de Godot Game Engine, se puede editar, exportar o ejecutar usando ese engine)

El objetivo de este programa es experimentar una teoria sobre el funcionamiento del envejecimiento tanto a nivel celular como 
en otros escenarios de la naturaleza y a diferentes escalas.

La idea es que el proceso de envejecimiento actua a modo de cuenta atras, y para crear una cuenta atras hace falta una unidad de memoria temporal, como un 
contador.

Cuando se habla de envejecimiento se suele creer que hay una cierta información celular en el ADN que va modificandose segun 
pasan los dias de vida y que las cosas van dejando de funcionar gradualmente.
El problema es que, de ser así, por estadistica, entre la infinidad de seres vivos que habitan la tierra podriamos encontrar 
casos de deformación o enfermedad genetica donde el resultado fuese la ausencia de envejecimiento, pero no es asi. (Se encuentran enfermedades geneticas que
aceleran el proceso de envejecimiento)

Es por ello que ese proceso regresivo cosidero que debe ser algo mas infalible que lo transmitible mediante información genetica.
Por ese motivo he desarrollado un algoritmo que se manifiesta como una cuenta regresiva en el funcionamiento optimo de unidades que comparten recursos entre si
y donde el resultado es un proceso que va desde un punto optimo y eficiente hasta un colapso final o muerte sin usar memoria a nivel 
temporal, solo un puñado de unidades o celulas o individuos interactuando entre si.

## en que consiste el algoritmo

Contamos con un conjunto de unidades, pueden ser celulas, sistemas o individuos segun la escala a la que queramos hacer referencia.
(El funcionamiento del algoritmo es el mismo para todas ellas, solo cambia el aspecto visual)

Estas unidades necesitan alimento periodicamente y transforman recursos primarios en alimento segun su eficiencia.
El punto importante es que cada unidad no se alimenta del alimento que ella produce, sino que todas las unidades reparten el alimento producido en cada cosecha.
