#ifndef NODOLISTADOCS_H
#define NODOLISTADOCS_H

#include "Documento.h"
#include <iostream>

class NodoListaDocs
{
    public:
        NodoListaDocs();
        NodoListaDocs(Documento doc, NodoListaDocs *sig = NULL);
        ~NodoListaDocs();

    protected:

    private:
        Documento documento; //Documento
        NodoListaDocs* siguiente; //Puntero al siguiente nodo
        friend class ListaDocs;
};

#endif // NODOLISTADOCS_H
