#ifndef NODOABB_H
#define NODOABB_H

#include <iostream>
#include <string>
#include "ListaDocs.h"

using namespace std;

class NodoABB
{
    friend class ABB;
    public:
        NodoABB(string dep, NodoABB *izq = NULL, NodoABB *der = NULL);
        virtual ~NodoABB();

        string getDepartamento();
        ListaDocs& getListaDocs();

    protected:

    private:
        string nombre;
        ListaDocs listaDocumentos;
        NodoABB *hi, *hd;
};

#endif // NODOABB_H
