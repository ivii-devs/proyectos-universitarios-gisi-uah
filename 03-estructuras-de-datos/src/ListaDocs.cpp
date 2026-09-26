#include "ListaDocs.h"
#include <iostream>

using namespace std;

ListaDocs::ListaDocs()
{
    primero = NULL;
    ultimo = NULL;
    longitud = 0;
}

ListaDocs::ListaDocs(const ListaDocs& otra)
{
    primero = NULL;
    ultimo = NULL;
    longitud = 0;

    NodoListaDocs *aux = otra.primero;
    while (aux) {
        insertarDere(aux->documento);
        aux = aux->siguiente;
    }
}

ListaDocs& ListaDocs::operator=(const ListaDocs& otra)
{
    if (this != &otra) {
        vaciarLista();
        NodoListaDocs *aux = otra.primero;
        while (aux) {
            insertarDere(aux->documento);
            aux = aux->siguiente;
        }
    }
    return *this;
}

ListaDocs::~ListaDocs()
{
    vaciarLista();
}

int ListaDocs::getLongitudListaDocs()
{
    return longitud;
}

bool ListaDocs::esVaciaListaDocs()
{
    return ((primero == NULL) && (ultimo == NULL));
}

void ListaDocs::insertarIzq(Documento documento)
{
    NodoListaDocs *nuevo_nodo = new NodoListaDocs(documento);

    if (esVaciaListaDocs()) {
        primero = nuevo_nodo;
        ultimo = nuevo_nodo;
    }
    else {
        nuevo_nodo->siguiente = primero;
        primero = nuevo_nodo;
    }
    longitud++;
}

void ListaDocs::insertarDere(Documento documento)
{
    NodoListaDocs *nuevo_nodo = new NodoListaDocs(documento);

    if (esVaciaListaDocs()) {
        primero = nuevo_nodo;
        ultimo = nuevo_nodo;
    }
    else {
        ultimo->siguiente = nuevo_nodo;
        ultimo = nuevo_nodo;
    }
    longitud++;
}

void ListaDocs::insertarEnPosicion(int posicion, Documento documento)
{
    if ((posicion >= 1) && (posicion <= (longitud + 1))) {
        if (posicion == 1) {
            insertarIzq(documento);
        }
        else if (posicion == (longitud + 1)) {
            insertarDere(documento);
        }
        else {
            NodoListaDocs *aux = primero;
            NodoListaDocs *nuevo_nodo = new NodoListaDocs(documento);

            for (int i = 1; i < posicion-1; i++) {
                aux = aux->siguiente;
            }

            nuevo_nodo->siguiente = aux->siguiente;
            aux->siguiente = nuevo_nodo;

            longitud++;
        }
    }
}

void ListaDocs::borrarIzq()
{
    if (!esVaciaListaDocs()) {
        NodoListaDocs *aux = primero;

        if (longitud == 1) {
            primero = NULL;
            ultimo = NULL;
            delete aux;
            longitud--;
        }
        else {
            primero = primero->siguiente;
            aux->siguiente = NULL;
            delete aux;
            longitud--;
        }
    }
}

void ListaDocs::borrarPosicion(int posicion)
{
    if (esVaciaListaDocs() || posicion < 1 || posicion > longitud) {
        cout << "No existe la posicion" << endl;
    }
    else {
        if (posicion == 1) {
            borrarIzq();
        }
        else {
            NodoListaDocs *aux = primero;

            for (int i = 1; i < posicion-1 ; i++) {
                aux = aux->siguiente;
            }
            NodoListaDocs *borrar = aux->siguiente;

            if (borrar->siguiente == NULL) {
                ultimo = aux;
            }

            aux->siguiente = borrar->siguiente;
            borrar->siguiente = NULL;

            delete borrar;
            longitud--;
        }
    }
}

void ListaDocs::vaciarLista()
{
    while (!esVaciaListaDocs()) {
        borrarIzq();
    }
}

Documento& ListaDocs::verPosicionListaDocs(int posicion)
{
    if (!esVaciaListaDocs()) {
        if (posicion < 1) posicion = 1;
        if (posicion > longitud) posicion = longitud;

        NodoListaDocs *aux = primero;

        for (int i = 1; i < posicion; i++) {
            aux = aux->siguiente;
        }

        return aux->documento;
    }
    static Documento dummy;
    return dummy;
}

void ListaDocs::mostrarListaDocs()
{
    NodoListaDocs *aux = primero;

    if (esVaciaListaDocs()) {
        cout << "Lista de documentos vacia." << endl;
    }
    else{
        while (aux) {
            aux->documento.mostrarDatos();
            cout << endl;
            aux = aux->siguiente;
        }
        cout << endl;
    }
}
