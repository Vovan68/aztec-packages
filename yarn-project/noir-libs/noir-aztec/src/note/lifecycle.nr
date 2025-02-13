use crate::context::Context;
use crate::note::{
    note_header::NoteHeader,
    note_interface::NoteInterface,
    utils::compute_inner_note_hash,
};
use crate::oracle::notes::{notify_created_note, notify_nullified_note};
use crate::constants_gen::EMPTY_NULLIFIED_COMMITMENT;
use crate::types::option::Option;

fn create_note<Note, N>(
    context: &mut Context,
    storage_slot: Field,
    note: &mut Note,
    note_interface: NoteInterface<Note, N>,
) {
    let mut inner_note_hash = 0;
    let contract_address = context.inputs.call_context.storage_contract_address;

    let header = NoteHeader { contract_address, storage_slot, nonce: 0 };
    let set_header = note_interface.set_header;
    set_header(note, header);
    inner_note_hash = compute_inner_note_hash(note_interface, *note);

    let serialise = note_interface.serialise;
    let preimage = serialise(*note);
    assert(notify_created_note(storage_slot, preimage, inner_note_hash) == 0);    

    context.push_new_note_hash(inner_note_hash);
}

fn destroy_note<Note, N>(
    context: &mut Context,
    storage_slot: Field,
    note: Note,
    note_interface: NoteInterface<Note, N>,
) {
    let mut nullifier = 0;
    let mut nullified_commitment = 0;
    let compute_nullifier = note_interface.compute_nullifier;
    nullifier = compute_nullifier(note);

    let serialise = note_interface.serialise;
    let preimage = serialise(note);
    
    // We also need the note commitment corresponding to the "nullifier"
    // TODO(suyash): We're re-computing the note commitment, ideally we can reuse the one already computed.
    nullified_commitment = compute_inner_note_hash(note_interface, note);
    assert(notify_nullified_note(storage_slot, nullifier, preimage, nullified_commitment) == 0);

    context.push_new_nullifier(nullifier, nullified_commitment)
}