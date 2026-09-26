#include "Cola.h"
#include "NodoCola.h"
#include "Documento.h"
#include <iostream>

using namespace std;

Cola::Cola()
{
    primero = NULL;
    ultimo = NULL;
    longitud = 0;
}

Cola::Cola(const Cola& otra)
{
    primero = NULL;
    ultimo = NULL;
    longitud = 0;

    NodoCola *aux = otra.primero;
    while (aux) {
        encolar(aux->documento);
        aux = aux->siguiente;
    }
}

Cola& Cola::operator=(const Cola& otra)
{
    if (this != &otra) {
        while (!esVaciaCola()) {
            desencolar();
        }
        NodoCola *aux = otra.primero;
        while (aux) {
            encolar(aux->documento);
            aux = aux->siguiente;
        }
    }
    return *this;
}

Cola::~Cola()
{
    while (!esVaciaCola()) {
        desencolar();
    }
}

bool Cola::esVaciaCola() {
    return ((primero == NULL) && (ultimo == NULL));
}

void Cola::encolar(Documento documento) {
    NodoCola *nuevo_nodo = new NodoCola(documento);
    if (esVaciaCola()) {
        primero = nuevo_nodo;
        ultimo = nuevo_nodo;
    }
    else {
        ultimo->siguiente = nuevo_nodo;
        ultimo = nuevo_nodo;
    }
}

void Cola::encolarPrioridad(Documento doc) {
    Cola colaAux; //Cola auxiliar para guardar los documentos temporales

    //Mover los documentos con menos prioridad a la cola auxiliar
    while (!esVaciaCola() && primero->documento.getPrioridad() > doc.getPrioridad()) {
        colaAux.encolar(primero->documento);
        desencolar();
    }

    //Encolamos el nuevo documento en su posicion correcta
    colaAux.encolar(doc);

    //Vaciamos la cola antigua y la encolamos en la auxiliar
    while (!esVaciaCola()) {
        colaAux.encolar(primero->documento);
        desencolar();
    }

    //Convertimos la cola auxiliar en nuestra cola principal
    primero = colaAux.primero;
    ultimo = colaAux.ultimo;
    colaAux.primero = NULL;
    colaAux.ultimo = NULL;
    longitud++;
}

void Cola::desencolar() {
    if (!esVaciaCola()) {
        NodoCola *aux = primero;

        if ((primero == ultimo) && (primero->siguiente == NULL)) {
            primero = NULL;
            ultimo = NULL;
            delete aux;
        }
        else {
            primero = primero->siguiente;
            delete aux;
        }
    }
}

int Cola::inicio() {
    if (!esVaciaCola()) {
        primero->documento.mostrarDatos();
    }
    return 0;
}

int Cola::fin() {
    if (!esVaciaCola()) {
        ultimo->documento.mostrarDatos();
    }
    return 0;
}

void Cola::mostrarCola() {
    NodoCola *aux = primero;

    if (esVaciaCola()) {
        cout << "Cola vacia" << endl;
    }
    else {
        int indice = 1;
        while(aux) {
            cout << indice << ". ";
            aux->documento.mostrarDatosSimp();
            aux = aux->siguiente;
            indice++;
        }
    }
}

Documento Cola::obtenerPrimero() {
    if (esVaciaCola()) {
        cout << "Cola Vacia" << endl;
        Documento vacio;
        return vacio;
    }
    else {
        return primero->documento;
    }
}

int Cola::getLongitud() {
    return longitud;
}

void Cola::disminuirLongitud() {
    if (longitud > 0) {
        longitud--;
    }
}
