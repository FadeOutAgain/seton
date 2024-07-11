/* Fonctions données par Quentin */

function copyTpl() {
    return document.querySelector('#tpl_notes').content.lastElementChild.cloneNode(true);
}

function createNote() {
    const t = window.prompt('Titre de la note ?');
    create(t, null).then((res) => {
        const id = res.result.id;
        insertNoteBlock(id, t, '', null, null, null);
        retrieve(id);
    });
}

function list() {
    fetch('/api/')
        .then((e) => { return e.json(); })
        .then((r) => {
            for (let l of r.notes) {
                insertNoteBlock(l.rowid, l.title, l.content, l.tag, l.dateCreated, l.dateUpdated);
            }
        });
}

function getNoteBlock(id) {
    return document.querySelector('li[data-noteid="' + id + '"]');
}

function tag(id, tag) {
    fetch('/api/' + id, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ 'tag': tag })
    })
        .then((e) => { return e.json(); })
        .then((r) => {
            if(null === tag) {
                delete getNoteBlock(id).dataset.tag;
            } else {
                getNoteBlock(id).dataset.tag = tag;
            }
        });
}

function untag(id) {
    tag(id, null);
}

function isTagged(id) {
    return ('important' == getNoteBlock(id).dataset.tag);
}


/* Génération de l'HTML de démarrage */ 

document.write("<H1>Gestionnaire de notes</H1>");
//document.write("<div class='MaNote'>Ma note 1</div>");
//document.write("<div class='MaNote'>Ma note 2</div>");
//document.write("<div class='MaNote'>Ma note 3</div>");

/* Insertion d'une liste à puces pour valider la consigne */

document.write('<ul><li>Partiel de développement web & mobile</li>');
document.write('<li>Benjamin MOREAU</li>');
document.write('<li>11/07/2024</li></ul>');

/* Association des fonctions aux liens "Nouvelle note" */ 

//window.addEventListener("load", copyTpl);
//ZoneDeNotes.InnerHTML = copyTpl();
//ZoneDeNotes.InnerHTML = "<div class='MaNote'>Ma note 4</div>";




function insertNoteBlock(id, title, content, tag, dateCreated, dateUpdated)
{
    console.log("insertNoteBlock " + id + " - " + title + " - " + content + " - " + tag + " - " + dateCreated + " - " + dateUpdated);
    const MaNouvelleNote = copyTpl();
    

    //MonFormulaire = MaNouvelleNote.querySelector('.noteform');
    //MonFormulaire.removeEventListener("submit");

    BoutonSauve =   MaNouvelleNote.querySelector(".save");
    BoutonTag =     MaNouvelleNote.querySelector(".tag");
    BoutonSuppr =   MaNouvelleNote.querySelector(".delete");


    MaNouvelleNote.dataset.id = id;
    MaNouvelleNote.dataset.tag = tag;

    // Emplacements cibles pour injecter les valeurs :

    const ptrTitre =       MaNouvelleNote.querySelector('input'); 
    const ptrTextArea =    MaNouvelleNote.querySelector('textarea');
    const ptrDateCreated = MaNouvelleNote.querySelector('.dateCreated');
    const ptrDateUpdated = MaNouvelleNote.querySelector('.dateUpdated ');
    

    // Injection des valeurs

    ptrTitre.value = title;
    ptrTextArea.value = content;
    ptrDateCreated.innerText = dateCreated;
    ptrDateUpdated.innerText = dateUpdated;
    
    const ZoneDeNotes = document.getElementById("notes");



    ZoneDeNotes.appendChild(MaNouvelleNote);
    console.log (MaNouvelleNote);
}
async function create(title, content)
{
    /*
    
    fetch('/api/')
        .then((e) => { return e.json(); })
        .then((r) => {
            for (let l of r.notes) {
                insertNoteBlock(l.rowid, l.title, l.content, l.tag, l.dateCreated, l.dateUpdated);
            }
        });

    */

// NE FONCTIONNE PAS DU TOUT :

const options = {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      title: title,
      content: content
    })
  };

    fetch('/api/',options)
        .then((e) => { return e.json(); })
        .then((r) => {
        });


}


function CreerUneNote(e){
    // console.log(e);
     e.preventDefault();    // évite le changement de page prévu par défaut.
    createNote();
    insertNoteBlock (789,"test3","contenu de ma note", 1,"10/07/2024","11/07/2024");
}


function PreparerLeDocument() {

     const MonHeader = document.querySelector('header');
     const MonFooter = document.querySelector('footer');
     
     MonHeader.addEventListener("click", CreerUneNote);
     MonFooter.addEventListener("click", CreerUneNote);

     insertNoteBlock (123,"test1","mon contenu 1", 0,"08/07/2024","09/07/2024")
     insertNoteBlock (456,"test2","mon contenu 2", 1,"08/07/2024","09/07/2024")
    
     list();
}


window.addEventListener("load", PreparerLeDocument);
