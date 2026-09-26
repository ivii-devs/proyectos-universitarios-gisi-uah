#ifndef ABB_H
#define ABB_H

#include "NodoABB.h"
#include "Documento.h"
#include <string>

using namespace std;

class ABB
{
    public:
        ABB();
        virtual ~ABB();

        void insertarDocumento(string depto, Documento doc);
        void insertarEnABB(NodoABB* nodo, string depto, Documento doc);

        void mostrarEnOrden();
        void mostrarEnOrden(NodoABB* nodo);

        void mostrarDeptos();
        void mostrarDeptos(NodoABB* nodo);

        void obtenerDepto();
        string obtenerDepto(NodoABB* nodo);

        ListaDocs buscarPorDepartamento(string depto);
        NodoABB* buscarEnABB(NodoABB* nodo, string depto);

        void buscarDeptoMasUsado(NodoABB* nodo, NodoABB*& masUsado);
        string obtenerDeptoMasUsado();
        void buscarDeptoMenosUsado(NodoABB* nodo, NodoABB*& menosUsado);
        string obtenerDeptoMenosUsado();

        void mostrarTiemposMediosDeptos();
        void mostrarTiemposMediosDeptos(NodoABB* nodo);

    protected:

    private:
        NodoABB *raiz;
        void destruir(NodoABB* nodo);
};

#endif // ABB_H
