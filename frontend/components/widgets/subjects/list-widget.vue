<template>
    <div>
        <v-data-table
            :headers="(headers as any[])"
            :items="props.data?.list || []"
            :loading="loading"
            :items-per-page="props.pageSize"
        >
            <template #bottom>
                <div class="text-center pt-2">
                    <v-pagination v-model="currentPage" :length="props.data?.pagination?.pages || 0" />
                </div>
            </template>
        </v-data-table>
    </div>
</template>
<script setup lang="ts">
const props = defineProps<{
    data: Shared.ListData<Subjects.ReadSubjectDTO> | null;
    loading: boolean;
    page: number;
    pageSize: number;
}>();

const emit = defineEmits<{
    (e: "page-changed", page: number): void;
}>();

const { t } = useI18n();
const dayjs = useDayjs();

const currentPage = computed({
    get: () => props.page,
    set: page => emit("page-changed", page)
});

const headers = computed(() => [
    {
        title: t("components.widgets.subjects.headers.id"),
        align: "start",
        sortable: false,
        key: "id"
    },
    {
        title: t("components.widgets.subjects.headers.title"),
        align: "start",
        sortable: false,
        key: "title"
    },
    {
        title: t("components.widgets.subjects.headers.shortTitle"),
        align: "start",
        sortable: false,
        key: "short_title"
    },
    {
        title: t("components.widgets.subjects.headers.insertedAt"),
        align: "start",
        sortable: false,
        key: "inserted_at",
        value: (item: Subjects.ReadSubjectDTO) => dayjs(item.inserted_at).format("DD.MM.YYYY HH:mm:ss")
    },
    {
        title: t("components.widgets.subjects.headers.updatedAt"),
        align: "start",
        sortable: false,
        key: "updated_at",
        value: (item: Subjects.ReadSubjectDTO) => dayjs(item.updated_at).format("DD.MM.YYYY HH:mm:ss")
    }
]);
</script>
