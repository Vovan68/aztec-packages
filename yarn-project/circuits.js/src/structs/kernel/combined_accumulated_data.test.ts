import { makeAccumulatedData } from '../../tests/factories.js';
import { CombinedAccumulatedData } from './combined_accumulated_data.js';

describe('CombinedAccumulatedData', () => {
  it('Data after serialization and deserialization is equal to the original', () => {
    const original = makeAccumulatedData();
    const afterSerialization = CombinedAccumulatedData.fromBuffer(original.toBuffer());
    expect(original).toEqual(afterSerialization);
  });
});
