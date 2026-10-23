import {
  AutocompleteInput,
  ReferenceInput,
  required,
} from "react-admin";

type ReferenceAutocompleteInputProps = {
  source: string;
  reference: string;
  searchField: string;
  label?: string;
  isRequired?: boolean;
  numericSearch?: boolean;
};

export const ReferenceAutocompleteInput = ({
  source,
  reference,
  searchField,
  label,
  isRequired = false,
  numericSearch = false,
}: ReferenceAutocompleteInputProps) => {
  const filterToQuery = (searchText: string) => {
    const searchTerm = searchText.trim();

    if (!searchTerm) {
      return {};
    }

    if (numericSearch) {
      return /^\d+$/.test(searchTerm)
        ? { [searchField]: searchTerm }
        : { [`${searchField}@lt`]: "0" };
    }

    return { [`${searchField}@ilike`]: searchTerm };
  };

  return (
    <ReferenceInput source={source} reference={reference} perPage={25}>
      <AutocompleteInput
        label={label}
        optionText="id"
        filterToQuery={filterToQuery}
        validate={isRequired ? required() : undefined}
      />
    </ReferenceInput>
  );
};
