package it.unisa.skillmarket.model;

import java.io.Serializable;

public class CategoriaBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idCategoria;
    private String nome;
    private String descrizione;

    public CategoriaBean() {
    }

    public int getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(int idCategoria) {
        this.idCategoria = idCategoria;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDescrizione() {
        return descrizione;
    }

    public void setDescrizione(String descrizione) {
        this.descrizione = descrizione;
    }

    @Override
    public String toString() {
        return "CategoriaBean{" +
                "idCategoria=" + idCategoria +
                ", nome='" + nome + '\'' +
                '}';
    }
}