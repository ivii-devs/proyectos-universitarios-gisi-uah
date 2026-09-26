#include <iostream>
#include <string>
#include "Sistema.h"

using namespace std;

void mostrarMenu() {
    cout << "=====================================================================" << endl;
    cout << "                        SISTEMA DE IMPRESORAS                        " << endl;
    cout << "=====================================================================" << endl;
    cout << "1.  Crear pila de documentos" << endl;
    cout << "2.  Mostrar pila de documentos" << endl;
    cout << "3.  Borrar pila de documentos" << endl;
    cout << "4.  Simular avance de N minutos" << endl;
    cout << "5.  Mostrar estado de impresoras" << endl;
    cout << "6.  Consultar impresora menos y mas ocupada" << endl;
    cout << "7.  Consultar numero de impresoras en funcionamiento" << endl;
    cout << "8.  Simular todo el proceso de impresion" << endl;
    cout << "9.  Anadir documento al arbol de documentos impresos" << endl;
    cout << "10. Mostrar arbol de documentos impresos" << endl;
    cout << "11. Mostrar documentos de un departamento" << endl;
    cout << "12. Mostrar departamentos que han impreso documentos" << endl;
    cout << "13. Departamento que ha utilizado mas/menos la red" << endl;
    cout << "14. Tiempo medio de impresion de un departamento" << endl;
    cout << "15. Mostrar tiempo medio de impresion de cada departamento" << endl;
    cout << "0.  Salir" << endl;
    cout << "======================================================================" << endl;
    cout << "Elige una opcion: ";
}

int main() {
    Sistema sistema;

    int opcion, minutos;
    string depto;

    do {
        mostrarMenu();
        if (!(cin >> opcion)) {
            break;
        }

        switch (opcion) {
        case 1:
            cout << "Creando pila de documentos..." << endl;
            sistema.crearDocumento();
            cout << "Documentos creados y almacenados en la pila." << endl;
            break;

        case 2:
            cout << "Mostrando pila de documentos: " << endl;
            sistema.mostrarPilaDocumentos();
            break;

        case 3:
            cout << "Borrando pila de documentos..." << endl;
            sistema.borrarPilaDocumentos();
            break;

        case 4:
            cout << "Introduce el numero de minutos a simular: " << endl;
            cin >> minutos;
            sistema.simularTiempo(minutos);
            break;

        case 5:
            cout << "Mostrando estado de las impresoras: " << endl;
            sistema.mostrarEstadoImpresoras();
            break;

        case 6:
            cout << "Impresora con menos documentos en cola: ID " << sistema.obtenerImpersoraMenosOcupada().getIdImpresora() << endl;
            cout << "Impresora con mas documentos en cola: ID " << sistema.obtenerImpersoraMasOcupada().getIdImpresora() << endl;
            break;

        case 7:
            cout << "Numero de impresoras en funcionamiento: " << sistema.obtenerNumImpresorasFuncionando() << endl;
            break;

        case 8:
            cout << "Simulando todo el proceso de impresion hasta que todos los documentos hayan sido procesados..." << endl;
            cout << "================================================================================================" << endl;
            sistema.simularTodo();
            break;

        case 9:
            sistema.insertarDocEnABB();
            cout << "=====================================" << endl;
            cout << "Nuevo documento insertado en el arbol" << endl;
            cout << "=====================================" << endl;
            break;

        case 10:
            cout << "Mostrando arbol de documentos de cada departamento..." << endl;
            cout << "======================================================" << endl;
            sistema.mostrarABB();
            break;

        case 11:
            cout << "Introduce un departamento: " << endl;
            cin >> depto;
            sistema.mostrarDocsDepto(depto);
            break;

        case 12:
            cout << "Mostrando departamentos que han utilizado la red: " << endl;
            cout << "===================================================" << endl;
            sistema.mostrarDeptos();
            break;

        case 13:
            cout << "===========================================" << endl;
            cout << "Departamentos que mas y menos han utilizado la red:" << endl;
            cout << "===========================================" << endl;
            sistema.deptoMasMenosUsado();
            break;

        case 14:
            cout << "Introduzca un departamento: " << endl;
            cin >> depto;
            cout << "====================================================" << endl;
            cout << "Mostrando tiempo medio de impresion del departamento " << depto << ": " << endl;
            cout << "====================================================" << endl;
            sistema.calcularTiempoImpresionDepto(depto);
            break;

        case 15:
            sistema.calcularTiempoImpresionGeneral();
            break;

        case 0:
            cout << "Saliendo del sistema..." << endl;
            break;
        }

        cout << endl;
    } while (opcion != 0);

    return 0;
}
