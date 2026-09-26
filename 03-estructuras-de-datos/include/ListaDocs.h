#ifndef LISTADOCS_H
#define LISTADOCS_H

#include "NodoListaDocs.h"
#include "Documento.h"

class ListaDocs
{
    public:
        ListaDocs();
        ListaDocs(const ListaDocs& otra);
        ListaDocs& operator=(const ListaDocs& otra);
        virtual ~ListaDocs();

        int getLongitudListaDocs();
        void insertarDere(Documento);
        void insertarIzq(Documento);
        void insertarEnPosicion(int, Documento);
        bool esVaciaListaDocs();
        Documento& verPosicionListaDocs(int);
        void borrarIzq();
        void borrarPosicion(int);
        void vaciarLista();
        void mostrarListaDocs();

    protected:

    private:
        NodoListaDocs * primero; //Puntero al primer Nodo
        NodoListaDocs * ultimo; //Puntero al ultimo nodo
        int longitud; //Cantidad de elementos en la lista
};

#endif // LISTADOCS_H
