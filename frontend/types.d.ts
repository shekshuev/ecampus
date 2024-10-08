type Locale = "en" | "ru";

declare namespace JWT {
    interface AccountInfo {
        id: number;
        email: string;
        roles: Account.Role[];
    }
    interface Payload {
        account: AccountInfo;
        aud: string;
        exp: number;
        iat: number;
        iss: string;
        jti: string;
        nbf: number;
        sub: string;
        type: string;
    }
}

declare namespace Shared {
    interface Notification {
        text: string;
        timeout: number;
        color: string;
    }

    interface Pagination {
        count: number;
        page: number;
        page_size: number;
        pages: number;
    }

    interface ListData<T> {
        pagination: Pagination;
        list: Array<T>;
    }
}

declare namespace Account {
    type Role = "admin" | "teacher" | "student";
}

declare namespace Specialities {
    interface ReadSpecialityDTO {
        id: 1;
        code: string;
        description: string;
        title: string;
        inserted_at: string;
        updated_at: string;
    }
}

declare namespace Groups {
    interface ReadGroupDTO {
        id: 1;
        title: string;
        description: string;
        speciality_id: number | null;
        inserted_at: string;
        updated_at: string;
    }
}

declare namespace Accounts {
    interface ReadAccountDTO {
        id: 1;
        email: string;
        first_name: string;
        last_name: string;
        group_id: number | null;
        roles: string[];
        inserted_at: string;
        updated_at: string;
    }
}

declare namespace Subjects {
    interface ReadSubjectDTO {
        id: number;
        title: string;
        short_title: string;
        description: string;
        objectives: string;
        prerequisites: string;
        required_texts: string;
        inserted_at: string;
        updated_at: string;
    }
}

declare namespace Lessons {
    interface CreateLessonDTO {
        is_draft: boolean;
        objectives: string;
        subject_id: number;
        title: string;
        topic: string;
        hours_count: number;
    }

    interface UpdateLessonDTO {
        is_draft?: boolean;
        objectives?: string;
        subject_id?: number;
        title?: string;
        topic?: string;
        hours_count?: number;
    }

    interface ReadLessonDTO extends CreateLessonDTO {
        id: number;
        inserted_at: string;
        updated_at: string;
    }

    interface CreateLessonTopicDTO {
        title: string;
        description: string;
        objectives: string;
        content: string;
        lesson_id: number;
    }

    interface UpdateLessonTopicDTO {
        title?: string;
        description?: string;
        objectives?: string;
        content?: string;
        lesson_id?: number;
    }

    interface ReadLessonTopicDTO extends CreateLessonTopicDTO {
        id: number;
        inserted_at: string;
        updated_at: string;
    }
}

declare namespace Classes {
    interface ReadClassGroupInfoDTO {
        id: number;
        title: string;
    }

    interface ReadClassTeacherDTO {
        id: number;
        first_name: string;
        last_name: string;
    }

    interface ReadClassLessonTopicInfoDTO {
        id: number;
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        content: any;
        title: string;
        lesson_id: number;
        inserted_at: string;
        updated_at: string;
    }

    interface ReadClassQuizQuestionAnswerDTO {
        id: number;
        title: string;
        subtitle: string;
    }

    interface ReadClassQuizQuestionDTO {
        id: number;
        type: "single" | "multiple" | "open" | "sequence" | "fill";
        title: string;
        subtitle: string;
        grade: number;
        quiz_id: number;
        answers: ReadClassQuizQuestionAnswerDTO[];
    }

    interface ReadClassQuizDTO {
        id: number;
        title: string;
        description: string;
        lesson_id: number;
        questions: ReadClassQuizQuestionDTO[];
        estimation: Record<string, string | number>;
    }

    interface ReadClassLessonInfoDTO {
        id: number;
        title: string;
        topic: string;
        topics: ReadClassLessonTopicInfoDTO[];
        teachers: ReadClassTeacherDTO[];
        quizzes: ReadClassQuizDTO[];
        hours_count: number;
        subject_id: number;
    }
    interface ReadClassDTO {
        id: number;
        begin_date: string;
        classroom: string;
        group: ReadClassGroupInfoDTO;
        lesson: ReadClassLessonInfoDTO;
        teachers: ReadClassTeacherDTO[];
        inserted_at: string;
        updated_at: string;
    }
}
