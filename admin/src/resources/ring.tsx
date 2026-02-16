import {
  List,
  Datagrid,
  TextField,
  ReferenceField,
  Show,
  SimpleShowLayout,
  Edit,
  SimpleForm,
  TextInput,
  ReferenceInput,
  SelectInput,
  required,
} from "react-admin";

const RingFilter = [
    <TextInput label="Search" source="id" alwaysOn />,
    <ReferenceInput source="animal" reference="animal" />,
    <TextInput label="Euring Code" source="euring_code" />,
];

export const RingList = () => (
  <List perPage={25} filters={RingFilter}>
    <Datagrid rowClick="show">
      <TextField source="id" />
      <ReferenceField source="animal" reference="animal" />
      <TextField source="euring_code" />
      <TextField source="colour_ring_colour" />
      <TextField source="colour_ring_code" />
    </Datagrid>
  </List>
);

export const RingShow = () => (
  <Show>
    <SimpleShowLayout>
      <TextField source="id" />
      <ReferenceField source="animal" reference="animal" />
      <TextField source="euring_code" />
      <TextField source="colour_ring_colour" />
      <TextField source="colour_ring_code" />
    </SimpleShowLayout>
  </Show>
);

export const RingEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="id" disabled />
      <ReferenceInput source="animal" reference="animal">
        <SelectInput validate={required()} />
      </ReferenceInput>
      <TextInput source="euring_code" />
      <TextInput source="colour_ring_colour" />
      <TextInput source="colour_ring_code" />
    </SimpleForm>
  </Edit>
);
