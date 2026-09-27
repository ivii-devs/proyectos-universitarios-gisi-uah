#ifndef LISTA_H
#define LISTA_H

#include "NodoLista.h"
#include "Impresora.h"

class Lista
{
    public:
        Lista();
        Lista(const Lista& otra);
        Lista& operator=(const Lista& otra);
        ~Lista();

        int getLongitudLista();
        void insertarDere(Impresora); //Inserta una impresora al final de la lista
        void insertarIzq(Impresora); //Inserta una impresora al principio de la lista
        void insertarEnPosicion(int, Impresora); //Inserta una impresora en una posicion especifica
        bool esVaciaLista();
        Impresora& verPosicion(int); //Obtiene la impresora de una posicion especifica
        void borrarIzq();
        void borrarPosicion(int);
        void vaciarLista();
        void mostrarLista();

    protected:

    private:
        NodoLista * primero; //Puntero al primer Nodo
        NodoLista * ultimo; //Puntero al ultimo nodo
        int longitud; //Cantidad de elementos en la lista
};

#endif // LISTA_H
