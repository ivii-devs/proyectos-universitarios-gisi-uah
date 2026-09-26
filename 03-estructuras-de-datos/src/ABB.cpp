#include "ABB.h"
#include <iostream>

using namespace std;

ABB::ABB() // Constructor con raiz ficticia para balancear el arbol
{
    raiz = new NodoABB("MM");
}

ABB::~ABB()
{
    destruir(raiz);
    raiz = NULL;
}

void ABB::destruir(NodoABB* nodo)
{
    if (nodo) {
        destruir(nodo->hi);
        destruir(nodo->hd);
        delete nodo;
    }
}

void ABB::insertarDocumento(string depto, Documento doc) {
    insertarEnABB(raiz, depto, doc);
}

void ABB::insertarEnABB(NodoABB* nodo, string depto, Documento doc) {
    if (!nodo) {
        return;
    }

    if (depto < nodo->nombre || depto == nodo->nombre) {
        if (nodo->hi == NULL) {
            NodoABB *nuevo = new NodoABB(depto);
            nodo->hi = nuevo;
            nuevo->listaDocumentos.insertarDere(doc);
        }
        else if (nodo->hi->nombre == depto) {
            nodo->hi->listaDocumentos.insertarDere(doc);
        }
        else {
            insertarEnABB(nodo->hi, depto, doc);
        }
    }
    else {
        if (nodo->hd == NULL) {
            NodoABB *nuevo = new NodoABB(depto);
            nodo->hd = nuevo;
            nuevo->listaDocumentos.insertarDere(doc);
        }
        else if (nodo->hd->getDepartamento() == depto) {
            nodo->hd->listaDocumentos.insertarDere(doc);
        }
        else {
            insertarEnABB(nodo->hd, depto, doc);
        }
    }
}

void ABB::mostrarEnOrden() {
    mostrarEnOrden(raiz);
}

void ABB::mostrarEnOrden(NodoABB* nodo) {
    if (nodo) {
        mostrarEnOrden(nodo->hi);
        if (nodo->getDepartamento() != "MM" || nodo->listaDocumentos.getLongitudListaDocs() > 0) {
            cout << "=====================================" << endl;
            cout << "Departamento: " << nodo->getDepartamento() << endl;
            cout << "=====================================" << endl;
            nodo->listaDocumentos.mostrarListaDocs();
            cout << endl;
        }
        mostrarEnOrden(nodo->hd);
    }
}

void ABB::mostrarDeptos() {
    mostrarDeptos(raiz);
}

void ABB::mostrarDeptos(NodoABB* nodo) {
    if (nodo) {
        mostrarDeptos(nodo->hi);
        if (nodo->getDepartamento() != "MM" || nodo->listaDocumentos.getLongitudListaDocs() > 0) {
            cout << "- " << nodo->getDepartamento() << endl;
        }
        mostrarDeptos(nodo->hd);
    }
}

void ABB::obtenerDepto() {
    obtenerDepto(raiz);
}

string ABB::obtenerDepto(NodoABB* nodo) {
    if (nodo) {
        return nodo->getDepartamento();
    }
    return "";
}

NodoABB* ABB::buscarEnABB(NodoABB* nodo, string depto) {
    if (!nodo) {
        return NULL;
    }

    if (depto < nodo->getDepartamento()) {
        return buscarEnABB(nodo->hi, depto);
    }
    else if (depto > nodo->getDepartamento()) {
        return buscarEnABB(nodo->hd, depto);
    }
    else {
        return nodo;
    }
}

ListaDocs ABB::buscarPorDepartamento(string depto) {
    NodoABB* resultado = buscarEnABB(raiz, depto);

    if (resultado) {
        cout << "Departamento encontrado: " << resultado->getDepartamento() << endl;
        cout << "Lista de documentos impresos en este departamento: " << endl;
        return resultado->getListaDocs();
    }
    else {
        cout << "El departamento " << depto << " no existe." << endl;
        ListaDocs vacia;
        return vacia;
    }
}

string ABB::obtenerDeptoMasUsado() {
    NodoABB* nodoMasUsado = NULL;
    buscarDeptoMasUsado(raiz, nodoMasUsado);

    if (nodoMasUsado) {
        return nodoMasUsado->getDepartamento();
    }
    return "Ninguno";
}

void ABB::buscarDeptoMasUsado(NodoABB* nodo, NodoABB*& masUsado) {
    if (!nodo) {
        return;
    }

    if (nodo->getDepartamento() != "MM" || nodo->getListaDocs().getLongitudListaDocs() > 0) {
        int docsNodo = nodo->getListaDocs().getLongitudListaDocs();
        if (docsNodo > 0) {
            if (masUsado == NULL || docsNodo > masUsado->getListaDocs().getLongitudListaDocs()) {
                masUsado = nodo;
            }
        }
    }

    buscarDeptoMasUsado(nodo->hi, masUsado);
    buscarDeptoMasUsado(nodo->hd, masUsado);
}

string ABB::obtenerDeptoMenosUsado() {
    NodoABB* nodoMenosUsado = NULL;
    buscarDeptoMenosUsado(raiz, nodoMenosUsado);

    if (nodoMenosUsado) {
        return nodoMenosUsado->getDepartamento();
    }
    return "Ninguno";
}

void ABB::buscarDeptoMenosUsado(NodoABB* nodo, NodoABB*& menosUsado) {
    if (!nodo) {
        return;
    }

    if (nodo->getDepartamento() != "MM" || nodo->getListaDocs().getLongitudListaDocs() > 0) {
        int docsNodo = nodo->getListaDocs().getLongitudListaDocs();
        if (docsNodo > 0) {
            if (menosUsado == NULL || docsNodo < menosUsado->getListaDocs().getLongitudListaDocs()) {
                menosUsado = nodo;
            }
        }
    }

    buscarDeptoMenosUsado(nodo->hi, menosUsado);
    buscarDeptoMenosUsado(nodo->hd, menosUsado);
}

void ABB::mostrarTiemposMediosDeptos() {
    mostrarTiemposMediosDeptos(raiz);
}

void ABB::mostrarTiemposMediosDeptos(NodoABB* nodo) {
    if (nodo) {
        mostrarTiemposMediosDeptos(nodo->hi);
        if (nodo->getDepartamento() != "MM" || nodo->listaDocumentos.getLongitudListaDocs() > 0) {
            int nDocs = nodo->listaDocumentos.getLongitudListaDocs();
            if (nDocs > 0) {
                int tiempoTotal = 0;
                for (int i = 1; i <= nDocs; i++) {
                    tiempoTotal += nodo->listaDocumentos.verPosicionListaDocs(i).getTiempoImpresion();
                }
                double media = static_cast<double>(tiempoTotal) / nDocs;
                cout << "- Departamento: " << nodo->getDepartamento()
                     << " | Documentos impresos: " << nDocs
                     << " | Tiempo medio de impresion: " << media << " minutos" << endl;
            }
        }
        mostrarTiemposMediosDeptos(nodo->hd);
    }
}
