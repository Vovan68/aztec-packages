use dep::std::hash::pedersen;
use dep::aztec::note::note_interface::NoteInterface;
use dep::aztec::note::note_header::NoteHeader;
use dep::aztec::note::utils::compute_unique_siloed_note_hash;
use dep::aztec::oracle::get_secret_key::get_secret_key;
use dep::aztec::oracle::get_public_key::get_public_key;

global ADDRESS_NOTE_LEN: Field = 1;

struct AddressNote {
    address: Field,
    header: NoteHeader,
}

impl AddressNote {
    fn new(address: Field) -> Self {
        AddressNote {
            address,
            header: NoteHeader::empty(),
        }
    }

    fn serialise(self) -> [Field; ADDRESS_NOTE_LEN] {
        let mut res: [Field; ADDRESS_NOTE_LEN] = [0; ADDRESS_NOTE_LEN];
        res[0] = self.address;
        res
    }

    fn compute_nullifier(self) -> Field {
        let unique_siloed_note_hash = compute_unique_siloed_note_hash(AddressNoteMethods, self);
        let owner_nullifying_public_key = get_public_key(self.address);
        let secret = get_secret_key(owner_nullifying_public_key);
        dep::std::hash::pedersen([
            unique_siloed_note_hash,
            secret,
        ])[0]
    }

    fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
    }

    fn dummy() -> Self {
        AddressNote {
            address: 0,
            header: NoteHeader::empty(),
        }
    }
}

fn deserialise(preimage: [Field; ADDRESS_NOTE_LEN]) -> AddressNote {
    AddressNote {
        address: preimage[0],
        header: NoteHeader::empty(),
    }
}

fn serialise(note: AddressNote) -> [Field; ADDRESS_NOTE_LEN] {
    note.serialise()
}

fn compute_note_hash(note: AddressNote) -> Field {
    dep::std::hash::pedersen(note.serialise())[0]
}

fn compute_nullifier(note: AddressNote) -> Field {
    note.compute_nullifier()
}

fn dummy() -> AddressNote {
    AddressNote::dummy()
}

fn get_header(note: AddressNote) -> NoteHeader {
    note.header
}

fn set_header(note: &mut AddressNote, header: NoteHeader) {
    note.set_header(header);
}

global AddressNoteMethods = NoteInterface {
    deserialise,
    serialise,
    compute_note_hash,
    compute_nullifier,
    dummy,
    get_header,
    set_header,
};
