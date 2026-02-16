import {
  List,
  Datagrid,
  TextField,
  NumberField,
  DateField,
  ReferenceField,
  Show,
  SimpleShowLayout,
  Edit,
  SimpleForm,
  TextInput,
  NumberInput,
  DateTimeInput,
  ReferenceInput,
  SelectInput,
  required,
} from "react-admin";

const LoggerInstrumentationFilter = [
    <TextInput label="Search" source="id" alwaysOn />,
    <ReferenceInput source="logger" reference="logger" />,
    <ReferenceInput source="deployment_id" reference="deployment" />,
    <TextInput label="Status" source="status" />,
    <TextInput label="Filename" source="filename" />,
];

export const LoggerInstrumentationList = () => (
  <List perPage={25} filters={LoggerInstrumentationFilter}>
    <Datagrid rowClick="show">
      <TextField source="id" />
      <ReferenceField source="logger" reference="logger" />
      <ReferenceField source="deployment_id" reference="deployment" />
      <TextField source="status" />
      <NumberField source="sampling_freq_s" />
      <TextField source="filename" />
      <DateField source="deployment" label="Deployment date" showTime />
      <DateField source="retrieval" showTime />
    </Datagrid>
  </List>
);

export const LoggerInstrumentationShow = () => (
  <Show>
    <SimpleShowLayout>
      <TextField source="id" />
      <ReferenceField source="logger" reference="logger" />
      <ReferenceField source="deployment_id" reference="deployment" />
      <TextField source="status" />
      <NumberField source="sampling_freq_s" />
      <NumberField source="mass_g" />
      <TextField source="attachment_method" />
      <TextField source="mount_method" />
      <DateField source="startup" showTime />
      <DateField source="deployment" label="Deployment date" showTime />
      <DateField source="retrieval" showTime />
      <TextField source="filename" />
      <TextField source="data_stored_externally" />
      <TextField source="comment" />
    </SimpleShowLayout>
  </Show>
);

export const LoggerInstrumentationEdit = () => (
  <Edit>
    <SimpleForm>
      <TextField source="id" />
      <ReferenceInput source="logger" reference="logger">
        <SelectInput validate={required()} />
      </ReferenceInput>
      <ReferenceInput source="deployment_id" reference="deployment">
        <SelectInput validate={required()} />
      </ReferenceInput>
      <TextInput source="status" />
      <NumberInput source="sampling_freq_s" />
      <NumberInput source="mass_g" />
      <TextInput source="attachment_method" />
      <TextInput source="mount_method" />
      <DateTimeInput source="startup" />
      <DateTimeInput source="deployment" label="Deployment date" />
      <DateTimeInput source="retrieval" />
      <TextInput source="filename" />
      <TextInput source="data_stored_externally" />
      <TextInput source="comment" multiline />
    </SimpleForm>
  </Edit>
);
