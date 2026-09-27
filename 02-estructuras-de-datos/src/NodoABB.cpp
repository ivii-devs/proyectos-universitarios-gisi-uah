#include "NodoABB.h"

NodoABB::NodoABB(string dep, NodoABB *izq, NodoABB *der)
{
    nombre = dep;
    hi = izq;
    hd = der;
    listaDocumentos = ListaDocs();
}

NodoABB::~NodoABB()
{
    //dtor
}

//void NodoABB::verNombre(){cout<<nombre<<endl;}

string NodoABB::getDepartamento() {
    return nombre;
}

ListaDocs& NodoABB::getListaDocs() {
    return listaDocumentos;
}
