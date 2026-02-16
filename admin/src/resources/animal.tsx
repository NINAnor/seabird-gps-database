import {
  List,
  Datagrid,
  TextField,
  Show,
  SimpleShowLayout,
  Edit,
  SimpleForm,
  TextInput,
  required,
} from "react-admin";

const AnimalFilter = [
    <TextInput label="Search" source="id" alwaysOn />,
    <TextInput label="Species" source="species" />,
    <TextInput label="Morph" source="morph" />,
];

export const AnimalList = () => (
  <List perPage={25} filters={AnimalFilter}>
    <Datagrid rowClick="show">
      <TextField source="id" />
      <TextField source="species" />
      <TextField source="morph" />
      <TextField source="subspecies" />
    </Datagrid>
  </List>
);

export const AnimalShow = () => (
  <Show>
    <SimpleShowLayout>
      <TextField source="id" />
      <TextField source="species" />
      <TextField source="morph" />
      <TextField source="subspecies" />
    </SimpleShowLayout>
  </Show>
);

export const AnimalEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="id" disabled />
      <TextInput source="species" validate={required()} />
      <TextInput source="morph" />
      <TextInput source="subspecies" />
    </SimpleForm>
  </Edit>
);
