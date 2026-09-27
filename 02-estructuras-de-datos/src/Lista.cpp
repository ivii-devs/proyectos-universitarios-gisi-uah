#include "Lista.h"
#include <iostream>

using namespace std;

Lista::Lista()
{
    primero = NULL;
    ultimo = NULL;
    longitud = 0;
}

Lista::Lista(const Lista& otra)
{
    primero = NULL;
    ultimo = NULL;
    longitud = 0;

    NodoLista *aux = otra.primero;
    while (aux) {
        insertarDere(aux->impresora);
        aux = aux->siguiente;
    }
}

Lista& Lista::operator=(const Lista& otra)
{
    if (this != &otra) {
        vaciarLista();
        NodoLista *aux = otra.primero;
        while (aux) {
            insertarDere(aux->impresora);
            aux = aux->siguiente;
        }
    }
    return *this;
}

Lista::~Lista()
{
    vaciarLista();
}

int Lista::getLongitudLista()
{
    return longitud;
}

bool Lista::esVaciaLista()
{
    return ((primero == NULL) && (ultimo == NULL));
}

void Lista::insertarIzq(Impresora impresora)
{
    NodoLista *nuevo_nodo = new NodoLista(impresora);

    if (esVaciaLista()) {
        primero = nuevo_nodo;
        ultimo = nuevo_nodo;
    }
    else {
        nuevo_nodo->siguiente = primero;
        primero = nuevo_nodo;
    }
    longitud++;
}

void Lista::insertarDere(Impresora impresora)
{
    NodoLista *nuevo_nodo = new NodoLista(impresora);

    if (esVaciaLista()) {
        primero = nuevo_nodo;
        ultimo = nuevo_nodo;
    }
    else {
        ultimo->siguiente = nuevo_nodo;
        ultimo = nuevo_nodo;
    }
    longitud++;
}

void Lista::insertarEnPosicion(int posicion, Impresora impresora)
{
    if ((posicion >= 1) && (posicion <= (longitud + 1))) {
        if (posicion == 1) {
            insertarIzq(impresora);
        }
        else if (posicion == (longitud + 1)) {
            insertarDere(impresora);
        }
        else {
            NodoLista *aux = primero;
            NodoLista *nuevo_nodo = new NodoLista(impresora);

            for (int i = 1; i < posicion-1; i++) {
                aux = aux->siguiente;
            }

            nuevo_nodo->siguiente = aux->siguiente;
            aux->siguiente = nuevo_nodo;

            longitud++;
        }
    }
}

Impresora& Lista::verPosicion(int posicion)
{
    if (!esVaciaLista()) {
        if (posicion < 1) posicion = 1;
        if (posicion > longitud) posicion = longitud;

        NodoLista *aux = primero;

        for (int i = 1; i < posicion; i++) {
            aux = aux->siguiente;
        }

        return aux->impresora;
    }
    static Impresora dummy;
    return dummy;
}

void Lista::borrarIzq()
{
    if (!esVaciaLista()) {
        NodoLista *aux = primero;

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

void Lista::borrarPosicion(int posicion)
{
    if (esVaciaLista() || posicion < 1 || posicion > longitud) {
        cout << "No existe la posicion" << endl;
    }
    else {
        if (posicion == 1) {
            borrarIzq();
        }
        else {
            NodoLista *aux = primero;

            for (int i = 1; i < posicion-1 ; i++) {
                aux = aux->siguiente;
            }
            NodoLista *borrar = aux->siguiente;

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

void Lista::vaciarLista()
{
    while (!esVaciaLista()) {
        borrarIzq();
    }
}

void Lista::mostrarLista()
{
    NodoLista *aux = primero;

    if (esVaciaLista()) {
        cout << "Lista Vacia" << endl;
    }
    else{
        while (aux) {
            aux->impresora.mostrarEstado();
            cout << endl;
            aux = aux->siguiente;
        }
        cout << endl;
    }
}
