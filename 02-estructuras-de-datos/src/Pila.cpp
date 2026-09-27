#include "Pila.h"

#include "NodoPila.h"
#include "Documento.h"
#include <iostream>

using namespace std;

Pila::Pila()
{
    cima = NULL;
    longitud = 0;
}

Pila::~Pila()
{
    while (cima) {
        desapilar();
    }
}

bool Pila::esVaciaPila() {
    return cima == NULL;
}

void Pila::apilar(Documento doc) {
    pnodo nuevo = new NodoPila(doc, cima);
    cima = nuevo;
}

void Pila::apilarTiempo(Documento doc) {
    Pila pilaAuxiliar; //Pila auxiliar para guardar los documentos temporales

    //Mover los documentos que tienen un tiempo de llegada menor al nuevo documento a la pila auxiliar
    while (!esVaciaPila() && cima->documento.getTiempoLlegada() < doc.getTiempoLlegada()) {
        pilaAuxiliar.apilar(cima->documento); //Mover a la pila auxiliar
        desapilar(); //Quitar de la pila original
    }

    //Apilar el nuevo documento en la posicion correcta
    apilar(doc);

    //Volver a apilar los documentos de la pila auxiliar a la pila original
    while (!pilaAuxiliar.esVaciaPila()) {
        apilar(pilaAuxiliar.cima->documento);
        pilaAuxiliar.desapilar();
    }
    longitud++;
}

void Pila::desapilar() {
    pnodo nodo; //puntero aux para manipular el nodo
    if (cima) {
        nodo = cima;
        cima = nodo->siguiente;
        delete nodo;
        if (longitud > 0) {
            longitud--;
        }
    }
}

void Pila::borrarPila() {
    while (!esVaciaPila()) {
        desapilar();
    }
}

int Pila::mostrarPilaCima() {
    if (esVaciaPila()) {
        cout << "Pila vacia." << endl;
    }
    else {
        cima->documento.mostrarDatos();
    }
    return 0;
}

void Pila::mostrarPila() {
    NodoPila *aux = cima;

    if (esVaciaPila()) {
        cout << "Pila vacia." << endl;
    }
    else {
        cout << "Datos de la Pila: " << endl;

        while (aux) {
            aux->documento.mostrarDatos();
            aux = aux->siguiente;
        }
    }
}

Documento Pila::mostrarDocumentoCima() {
    if (esVaciaPila()) {
        cout << "Pila Vacia" << endl;
        Documento vacio;
        return vacio;
    }
    else {
        return cima->documento;
    }
}

int Pila::getLongitud() {
    return longitud;
}
