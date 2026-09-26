#include "Sistema.h"
#include <iostream>

using namespace std;

Sistema::Sistema()
{
    // La simulacion comienza en el minuto 0 de las 7:00
    this->tiempoActual = 0;

    // Total de documentos que va a manejar el sistema
    this->totalDocumentos = 0;

    // Impresora inicial con ID 0
    Impresora impresoraInicial(0);

    // Insertamos la impresora inicial en la lista de impresoras
    listaImpresoras.insertarDere(impresoraInicial);

    // Tiempo total de estancia de los documentos en el sistema inicializado a 0
    this->tiempoTotalSistema = 0;
    this->tiempoMedioImpresion = 0.0;
}

Sistema::~Sistema()
{
    // dtor
}

void Sistema::crearDocumento() {
    pila.apilarTiempo(Documento(1, 0, 10, "Compras", 6));
    pila.apilarTiempo(Documento(2, 0, 15, "Nominas", 1));
    pila.apilarTiempo(Documento(3, 5, 29, "Direccion", 7));
    pila.apilarTiempo(Documento(4, 7, 8, "Ventas", 5));
    pila.apilarTiempo(Documento(5, 9, 16, "Direccion", 7));
    pila.apilarTiempo(Documento(6, 9, 13, "Compras", 6));
    pila.apilarTiempo(Documento(7, 10, 10, "Compras", 6));
    pila.apilarTiempo(Documento(8, 10, 15, "Nominas", 1));
    pila.apilarTiempo(Documento(9, 15, 29, "Direccion", 7));
    pila.apilarTiempo(Documento(10, 17, 8, "Ventas", 5));
    pila.apilarTiempo(Documento(11, 19, 16, "Direccion", 7));
    pila.apilarTiempo(Documento(12, 19, 13, "Compras", 6));
    pila.apilarTiempo(Documento(13, 10, 15, "Nominas", 1));
    pila.apilarTiempo(Documento(14, 15, 29, "Direccion", 7));
    pila.apilarTiempo(Documento(15, 17, 8, "Ventas", 5));
    pila.apilarTiempo(Documento(16, 19, 16, "Direccion", 7));
    pila.apilarTiempo(Documento(17, 19, 13, "Compras", 6));

    totalDocumentos += pila.getLongitud();
}

void Sistema::mostrarPilaDocumentos() {
    pila.mostrarPila();
}

void Sistema::borrarPilaDocumentos() {
    pila.borrarPila();
}

void Sistema::mostrarEstadoImpresoras() {
    listaImpresoras.mostrarLista();
}

int Sistema::getTiempoActual() {
    return tiempoActual;
}

bool Sistema::hayImpresorasOcupadas() {
    for (int i = 1; i <= listaImpresoras.getLongitudLista(); i++) {
        if (!listaImpresoras.verPosicion(i).estaLibre() || !listaImpresoras.verPosicion(i).getColaDocumentos().esVaciaCola()) {
            return true;
        }
    }
    return false;
}

void Sistema::simularUnMinuto() {
    // Si la pila no esta vacia y la hora de llegada del doc de su cima coincide con la hora actual:
    while (!pila.esVaciaPila() && pila.mostrarDocumentoCima().getTiempoLlegada() == tiempoActual) {
        Documento docActual = pila.mostrarDocumentoCima();
        pila.desapilar();
        agregarDocumentoImpresoraMenosOcupada(docActual);
    }

    // Actualizar impresoras: Recorremos la lista 1-indexada
    for (int i = 1; i <= listaImpresoras.getLongitudLista(); i++) {
        if (!listaImpresoras.verPosicion(i).estaLibre()) {
            if (listaImpresoras.verPosicion(i).actualizar(0)) {
                int tiempoLlegadaDoc = listaImpresoras.verPosicion(i).getDocumentoActual().getTiempoLlegada();
                int tiempoTotalDoc = tiempoActual - tiempoLlegadaDoc;
                tiempoTotalSistema += tiempoTotalDoc;

                Documento doc = listaImpresoras.verPosicion(i).getDocumentoActual();
                string depto = listaImpresoras.verPosicion(i).getDocumentoActual().getDepartamento();

                arbolDepartamentos.insertarDocumento(depto, doc);
                listaImpresoras.verPosicion(i).liberar();
            }
        }
    }
    tiempoActual++;
}

void Sistema::simularTiempo(int minutos) {
    for (int i = 0; i < minutos; i++) {
        cout << "==============================================================" << endl;
        cout << "SIMULANDO MINUTO - " << tiempoActual << endl;
        cout << "--------------------------------------------------------------" << endl;
        cout << endl;
        simularUnMinuto();
        cout << endl;
        cout << "==============================================================" << endl;
    }
    cout << endl;
    cout << "///  Simulacion de " << minutos << " minutos finalizada.  ///" << endl;
    cout << "///  Hora actual: " << tiempoActual << " minutos desde las 7:00  ///" << endl;
}

void Sistema::simularTodo() {
    while (!pila.esVaciaPila() || hayImpresorasOcupadas()) {
        simularUnMinuto();
    }
    if (totalDocumentos > 0) {
        tiempoMedioImpresion = static_cast<double>(tiempoTotalSistema) / totalDocumentos;
    } else {
        tiempoMedioImpresion = 0.0;
    }

    cout << "==============================================================" << endl;
    cout << "Simulacion completa: Todos los documentos han sido procesados." << endl;
    cout << "Hora actual: " << tiempoActual << " minutos desde las 7:00" << endl;
    cout << "Tiempo medio de estancia en el Sistema: " << tiempoMedioImpresion << " minutos" << endl;
    cout << "==============================================================" << endl;
}

Impresora Sistema::obtenerImpersoraMasOcupada() {
    if (listaImpresoras.esVaciaLista()) {
        Impresora vacia(-1);
        return vacia;
    }
    Impresora masOcupada = listaImpresoras.verPosicion(1);

    for (int i = 2; i <= listaImpresoras.getLongitudLista(); i++) {
        if (listaImpresoras.verPosicion(i).getColaDocumentos().getLongitud() > masOcupada.getColaDocumentos().getLongitud()) {
            masOcupada = listaImpresoras.verPosicion(i);
        }
    }
    return masOcupada;
}

Impresora Sistema::obtenerImpersoraMenosOcupada() {
    if (listaImpresoras.esVaciaLista()) {
        Impresora vacia(-1);
        return vacia;
    }
    Impresora menosOcupada = listaImpresoras.verPosicion(1);

    for (int i = 2; i <= listaImpresoras.getLongitudLista(); i++) {
        if (listaImpresoras.verPosicion(i).getColaDocumentos().getLongitud() < menosOcupada.getColaDocumentos().getLongitud()) {
            menosOcupada = listaImpresoras.verPosicion(i);
        }
    }
    return menosOcupada;
}

int Sistema::obtenerNumImpresorasFuncionando() {
    int enFuncionamiento = 0;
    for (int i = 1; i <= listaImpresoras.getLongitudLista(); i++) {
        if (!listaImpresoras.verPosicion(i).estaLibre()) {
            enFuncionamiento++;
        }
    }
    return enFuncionamiento;
}

void Sistema::agregarDocumentoImpresoraMenosOcupada(Documento doc) {
    int posicionMenosOcupada = -1;
    int menorLongitudCola = 3;

    for (int i = 1; i <= listaImpresoras.getLongitudLista(); i++) {
        int longitudColaActual = listaImpresoras.verPosicion(i).getColaDocumentos().getLongitud();
        if (longitudColaActual < menorLongitudCola) {
            menorLongitudCola = longitudColaActual;
            posicionMenosOcupada = i;
        }
    }

    if (posicionMenosOcupada != -1) {
        listaImpresoras.verPosicion(posicionMenosOcupada).agregarDocumentoCola(doc);
    }
    else {
        Impresora nuevaImpresora(listaImpresoras.getLongitudLista());
        nuevaImpresora.agregarDocumentoCola(doc);
        listaImpresoras.insertarDere(nuevaImpresora);

        cout << "Nueva Impresora anadida al Sistema de Impresion (ID: " << nuevaImpresora.getIdImpresora() << ")" << endl;
        cout << endl;
    }
}

void Sistema::eliminarImpresorasLibres() {
    for (int i = 1; i <= listaImpresoras.getLongitudLista(); ) {
        if ((listaImpresoras.verPosicion(i).estaLibre() && listaImpresoras.verPosicion(i).getColaDocumentos().esVaciaCola()) && listaImpresoras.getLongitudLista() > 1) {
            listaImpresoras.borrarPosicion(i);
        } else {
            i++;
        }
    }
}

void Sistema::mostrarABB() {
    arbolDepartamentos.mostrarEnOrden();
}

void Sistema::mostrarDocsDepto(string depto) {
    arbolDepartamentos.buscarPorDepartamento(depto).mostrarListaDocs();
}

void Sistema::mostrarDeptos() {
    arbolDepartamentos.mostrarDeptos();
}

void Sistema::insertarDocEnABB() {
    int idDoc, tiempoLlegada, tiempoImpresion, prioridad;
    string depto;

    cout << "Introduzca los datos del documento: " << endl;
    cout << "======================================" << endl;
    cout << "Introduzca ID: " << endl;
    cin >> idDoc;
    cout << "Introduzca el tiempo de llegada: " << endl;
    cin >> tiempoLlegada;
    cout << "Introduzca el tiempo de impresion: " << endl;
    cin >> tiempoImpresion;
    cout << "Introduzca la prioridad: " << endl;
    cin >> prioridad;
    cout << "Introduzca el departamento: " << endl;
    cin >> depto;

    Documento doc(idDoc, tiempoLlegada, tiempoImpresion, depto, prioridad);
    arbolDepartamentos.insertarDocumento(depto, doc);
}

void Sistema::calcularTiempoImpresionDepto(string depto) {
    ListaDocs docs = arbolDepartamentos.buscarPorDepartamento(depto);
    int nDocs = docs.getLongitudListaDocs();

    if (nDocs == 0) {
        cout << "No hay documentos registrados para el departamento " << depto << "." << endl;
        return;
    }

    int tiempoImpresionDepto = 0;
    for (int i = 1; i <= nDocs; i++) {
        tiempoImpresionDepto += docs.verPosicionListaDocs(i).getTiempoImpresion();
    }

    double tiempoMedioDepto = static_cast<double>(tiempoImpresionDepto) / nDocs;

    cout << "Tiempo medio de impresion del departamento " << depto << ": " << tiempoMedioDepto << " minutos." << endl;
}

void Sistema::calcularTiempoImpresionGeneral() {
    cout << "========================================================" << endl;
    cout << "  TIEMPO MEDIO DE IMPRESION DE CADA DEPARTAMENTO (ABB)   " << endl;
    cout << "========================================================" << endl;
    arbolDepartamentos.mostrarTiemposMediosDeptos();
    cout << "========================================================" << endl;
}

void Sistema::deptoMasMenosUsado() {
    string masUsado = arbolDepartamentos.obtenerDeptoMasUsado();
    string menosUsado = arbolDepartamentos.obtenerDeptoMenosUsado();

    cout << "Departamento mas utilizado: " << masUsado << endl;
    cout << "Departamento menos utilizado: " << menosUsado << endl;
}
